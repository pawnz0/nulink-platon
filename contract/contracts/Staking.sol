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
    uint256 public totalReward;
    uint256 public totalStakeBalance;

    mapping(address => staker) public stakerInfo;
    mapping(address => uint256) public stakerReward;
    mapping(address => bool) public managers;

    constructor (IERC20 _stakeToken, address _manager, uint256 _stakaAmount, uint256 _totalReward){
        sToken = _stakeToken;
        managers[msg.sender] = true;
        managers[_manager] = true;
        stakeAmount = _stakaAmount;
        totalReward = _totalReward;
    }

    modifier onlyManager() {
        require(isManager(msg.sender), "FORBIDDEN");
        _;
    }

    function isManager(address _sender) view public returns (bool){
        return managers[_sender];
    }

    function setTotalReword(uint256 _totalReward) public onlyManager {
        // require(_totalReward > 0, "total reward must be greater than 0");
        totalReward = _totalReward;
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
            workcount:0,
            isWork: true
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

        bool isFirst = false;
        uint256 reward;
        staker memory newStaker;

        newStaker = staker({
            owner: _owner,
            stakeToken: sToken,
            stakeBalance: _balance,
            workcount: _workCount,
            isWork: _isWork
        });

        stakerInfo[_owner] = newStaker;
        if (totalStakeBalance == 0) {
            totalStakeBalance += _balance;
            isFirst = true;
        }

        reward = calcReward(totalStakeBalance, _balance);
        if (reward != 0) {
            stakerReward[_owner] += reward;
        }
        if (!isFirst) {
            totalStakeBalance += _balance;
        }
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

    function calcReward(uint256 _totalStakeBalance, uint256 _stakeBalance) public view returns (uint256) {
        require(_totalStakeBalance > 0, "total stake balance is not set");
        if (totalReward == 0 || _stakeBalance == 0 ) {
            return 0;
        }
        return totalReward * _stakeBalance / _totalStakeBalance;
    }

    function claim(uint64 _amount) public {
        require(stakerReward[msg.sender] >= _amount, "insufficient balance");

        sToken.safeTransferFrom(address(this), msg.sender, _amount);
        stakerReward[msg.sender] -= _amount;
    }
}