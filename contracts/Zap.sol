// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IRouter.sol";
import "./interfaces/IFactory.sol";

contract Zap is Ownable, ReentrancyGuard {
    // Factory to create LP
    IFactory public immutable factory =
        IFactory(0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32);

    // Router to swap and add liquidity
    IRouter public immutable router =
        IRouter(0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff);

    // Receives ZAP fees
    address public immutable dev = 0xDAcE7384A746126c97E76B80a3651c30839E3B54;

    // ERC20 token to swap for
    address private immutable erc20 =
        0xe88Ac56C4dedc973a0a26C062F0F07568dfb23FA;

    // WETH address
    address private immutable weth = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;

    // Route to swap from native to erc20
    address[] public nativeRoute = new address[](2);

    constructor() Ownable(msg.sender) {
        nativeRoute[0] = weth;
        nativeRoute[1] = erc20;
        giveAllowances();
    }

    function giveAllowances() public onlyOwner {
        IERC20(erc20).approve(address(router), type(uint).max);
        IERC20(weth).approve(address(router), type(uint).max);
    }

    function zap() external payable nonReentrant {
        uint256 balance = address(this).balance;
        uint256 halfBalance = balance / 2;

        // swap half of native for ERC20 token
        router.swapExactETHForTokens{value: halfBalance}(
            1,
            nativeRoute,
            address(this),
            block.timestamp
        );

        // create LP
        router.addLiquidityETH{value: address(this).balance}(
            erc20,
            IERC20(erc20).balanceOf(address(this)),
            (IERC20(erc20).balanceOf(address(this)) * 975) / 1000,
            (halfBalance * 975) / 1000,
            address(this),
            block.timestamp
        );

        // send to user
        address lpAddress = factory.getPair(nativeRoute[0], nativeRoute[1]);
        if (lpAddress == 0x0000000000000000000000000000000000000000) {
            lpAddress = factory.createPair(nativeRoute[0], nativeRoute[1]);
        }
        sendLpToUser(lpAddress);

        // sweep
        sweep();
    }

    function sendLpToUser(address _lpAddress) private {
        IERC20 lp = IERC20(_lpAddress);
        lp.transfer(tx.origin, lp.balanceOf(address(this)));
    }

    function sweep() private {
        // sweep erc20
        if (IERC20(erc20).balanceOf(address(this)) > 0)
            IERC20(erc20).transfer(dev, IERC20(erc20).balanceOf(address(this)));

        // sweep weth
        if (IERC20(weth).balanceOf(address(this)) > 0)
            IERC20(weth).transfer(dev, IERC20(weth).balanceOf(address(this)));

        // sweep native
        if (address(this).balance > 0)
            payable(address(dev)).call{value: address(this).balance}(
                new bytes(0)
            );
    }

    // emergency function to withdraw any token
    function ownerWithdraw(IERC20 _token) public onlyOwner {
        _token.transfer(owner(), _token.balanceOf(address(this)));
    }

    receive() external payable {}

    fallback() external payable {}
}
