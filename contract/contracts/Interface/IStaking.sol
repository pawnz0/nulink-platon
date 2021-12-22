// SPDX-License-Identifier: MIT 
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
pragma solidity ^0.8.0;
interface IStaking{
    
    struct staker{
        address   owner;
        IERC20   stakeToken;
        uint256   stakeBalance;
        uint256   workcount;
    }

    struct policy {
        uint256 policyid;
        uint256 rewardBalnce;
        uint256 begin;
        uint256 end;
        address[] stakers;
        mapping(address => uint256) stakerInBlock;
    }
}