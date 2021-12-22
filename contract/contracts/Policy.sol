// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0;

import "./Interface/IStaking.sol";
import "./Interface/IStaking.sol";
import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Policy is Ownable,IStaking{
    using SafeERC20 for IERC20;
    using SafeMath for uint256 ;
    address staking;
    
}