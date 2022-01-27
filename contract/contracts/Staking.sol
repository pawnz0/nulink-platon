// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Interface/IStaking.sol";
import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Staking is Ownable, IStaking {

    using SafeERC20 for IERC20;

    IERC20 sToken; // stake Token

    uint256 public totalReward;
    uint256 public totalStakeBalance;

    address[] public stakers;
    mapping(address => staker) public stakerInfo;  // staker address ==> staker
    mapping(address => uint256) public stakerReward;  // staker address ==> reward
    mapping(address => bool) public managers;  // manager address ==> is manager

    constructor (IERC20 _stakeToken, address _manager, uint256 _reward){
        sToken = _stakeToken;
        managers[msg.sender] = true;
        managers[_manager] = true;
        if (_reward > 0) {
            sToken.safeTransferFrom(msg.sender, address(this), _reward);
            totalReward = _reward;
        }
    }

//    receive() external payable {
//        totalReward += msg.value;
//    }

    function addReward(uint256 _reward) public {
        // require(_totalReward > 0, "total reward must be greater than 0");
        sToken.safeTransferFrom(msg.sender, address(this), _reward);
        totalReward += _reward;
    }

    modifier onlyManager() {
        require(isManager(msg.sender), "FORBIDDEN");
        _;
    }

    function isManager(address _sender) view public returns (bool){
        return managers[_sender];
    }

    /**
     * @dev isStaker to check the staker
     */
    function isStaker(address _user) public override view returns (bool){
        return stakerInfo[_user].owner == _user ? true : false;
    }

    function updateStaker(address _owner, uint256 _balance, uint256 _workCount, bool _isWork) private {
        require(_balance > 0, "stake balance not set");

        staker memory newStaker;

        newStaker = staker({
            owner: _owner,
            stakeToken: sToken,
            stakeBalance: _balance,
            workcount: _workCount,
            isWork: _isWork
        });

        // staker not exits
        if (stakerInfo[_owner].owner == address(0)) {
            stakers.push(_owner);
        }
        stakerInfo[_owner] = newStaker;
        totalStakeBalance += _balance;
    }

    function UpdateStakers(address[] memory _owners, uint256[] memory _balances, uint256[] memory _workCounts, bool[] memory _isWorks) public {
        require(_owners.length == _balances.length && _workCounts.length == _isWorks.length && _owners.length == _workCounts.length, "invalid parameter");
        for (uint256 i = 0; i < _owners.length; i++) {
            updateStaker(_owners[i], _balances[i], _workCounts[i], _isWorks[i]);
        }
        giveOutReward();
    }

    function giveOutReward() private {
        for (uint256 i = 0; i < stakers.length; i++) {
            if (totalReward <= 0) {
                return;
            }
            staker memory s = stakerInfo[stakers[i]];
            uint256 reward = calcReward(totalStakeBalance, s.stakeBalance);
            if (reward > 0 && reward < totalReward) {
                totalReward -= reward;
                stakerReward[s.owner] += reward;
            }
        }
    }

    function calcReward(uint256 _totalStakeBalance, uint256 _stakeBalance) private view returns (uint256) {
        require(_totalStakeBalance > 0, "total stake balance is not set");
        if (totalReward == 0 || _stakeBalance == 0) {
            return 0;
        }
        return totalReward * _stakeBalance / _totalStakeBalance;
    }

    function claim(uint256 _amount) public {
        require(stakerReward[msg.sender] >= _amount, "insufficient balance");

        sToken.safeTransferFrom(address(this), msg.sender, _amount);
        stakerReward[msg.sender] -= _amount;
    }
}