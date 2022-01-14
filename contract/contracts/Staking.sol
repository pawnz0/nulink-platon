// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Interface/IStaking.sol";
import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Staking is Ownable,IStaking{
    
    using SafeERC20 for IERC20;
    
    IERC20 sToken; // stake Token
    
     //@stakeAmount to be staker need staking amount .
    uint256 stakeAmount; 
    
    mapping(address => staker) public stakerInfo;
    
    constructor (IERC20 _stakeToken,uint256 _stakaAmount){
        sToken = _stakeToken;
        stakeAmount = _stakaAmount;
    } 
    
    /**
     * @dev newStaker is user to be a new staker 
     */
    function newStaker() public{
        require(stakeAmount > 0, "stakeAmount amount not set");
        staker memory lockstaker = stakerInfo[msg.sender];
        require(lockstaker.owner == address(0),"is staker");
        
        // new staker 
        lockstaker = staker({
            owner : msg.sender,
            stakeToken : sToken,
            stakeBalance: stakeAmount,
            workcount:0
        });
        
        stakerInfo[msg.sender] = lockstaker;
        
        //transfer
        sToken.safeTransferFrom(msg.sender,address(this),stakeAmount);
    }

    /**
    * @dev updateStaker
     */
    function updateStaker(address _owner, uint256 _balance, uint8 _workCount, bool _isWork) public {
        require(_balance > 0, "stake balance not set");

        staker memory newStaker;
        newStaker = staker({
            owner: _owner,
            stakeToken: sToken,
            stakeBalance: _balance,
            workcount: _workCount,
            isWork: _isWork
        });

        stakerInfo[_owner] = newStaker;
    }
    
    /**
     * @dev leaveStaker is user to leave staker 
     */
    function leaveStaker() public{
        staker storage lockstaker = stakerInfo[msg.sender];
        require(isStaker(msg.sender),"is not staker");
        
        lockstaker.owner = address(0);
        
        //transfer
        lockstaker.stakeToken.safeTransfer(msg.sender,lockstaker.stakeBalance);
        
    }
    
    /**
     * @dev isStaker to check the staker  
     */
    function isStaker(address _user) public override view returns(bool){
        return stakerInfo[_user].owner == _user? true:false;
        
    }
    
    
    /**
     * @dev setStakeInfo to update stake info stake token and stakeamount 
     */
    function updateStakeInfo(IERC20 _stakeToken,uint256 _stakaAmount)  public onlyOwner{
        sToken = _stakeToken;
        stakeAmount = _stakaAmount;
    }
    
     
    
}