// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0;

import "./Interface/IStaking.sol";
import "./Interface/IStaking.sol";
import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract Policy is Ownable{
    using SafeERC20 for IERC20;
    using SafeMath for uint256 ;
    using Address for address;
    
    IStaking staking;
    
    uint256 pID;
    
    struct policy {
        uint256 policyid;
        uint256 rewardBalnce;
        uint256 begin;
        uint256 end;
        address[] stakers;
        mapping(address => uint256) stakerInBlock;
    }
    
    
    
    constructor(IStaking _staking) {
        //require(_staking.isContract(),"only staking is controller");
        staking = _staking;
    }
    
    
    
    
    
}