// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0;

import "./Interface/IStaking.sol";
import "./Interface/IStaking.sol";
import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract Policy is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using Address for address;

    IStaking staking;

    uint256  public pID;
    IERC20  public rewardToken;

    struct policy {
        uint256 policyID;
        address creater;
        uint256 rewardBalance;
        uint256 begin;
        uint256 end;
        uint256 cancelBlock;
        address[] stakers;
    }

    uint256[]  public policyIDList;
    mapping(uint256 => policy) public policyInfo;  // policyID ==> policy
    mapping(address => uint256) public stakerReward; // staker address ==> reward
    mapping(uint256 => uint256) public policyRewardedBlock; // policyID ==> rewarded block

    constructor(IStaking _staking, IERC20 _rewardToken) {
        //require(_staking.isContract(),"only staking is controller");
        require(address(_rewardToken).isContract(), "only reward token is controller");
        staking = _staking;
        rewardToken = _rewardToken;
    }

    function checkStaker(address[] memory _stakerAddresses) view internal returns (bool){
        for (uint256 i = 0; i < _stakerAddresses.length; i++) {
            if (!staking.isStaker(_stakerAddresses[i])) {
                return false;
            }
        }
        return true;
    }

    /**
     * @dev createPolicy any user can create ther policy
 */
    function createPolicy(address[] memory _stakerAddresses, uint256 _rewardBalance, uint256 _begin, uint256 _end) public returns (uint256) {
        //check staker
        require(checkStaker(_stakerAddresses), "staker address not staker");
        require(_end > _begin && _begin >= block.number, "create begin and end is illegal");
        require(_rewardBalance > 0, "reward balance must big zero");

        pID += 1;

        rewardToken.safeTransferFrom(msg.sender, address(this), _rewardBalance);

        policyInfo[pID] = policy({
            policyID: pID,
            creater: msg.sender,
            rewardBalance: _rewardBalance,
            begin: _begin,
            end: _end,
            cancelBlock: 0,
            stakers: _stakerAddresses
        });
        policyIDList.push(pID);

        return pID;
    }

    function cancelPolicy(uint256 _pid) public {
        policy storage pl = policyInfo[_pid];
        require(pl.creater == msg.sender, "this create not right");
        require(pl.cancelBlock == 0, "already canceled ");
        require(pl.end > block.number, "policy has expired");

        pl.cancelBlock = block.number;
        uint256 reward = calcReward(pl);
        for (uint256 i = 0; i < pl.stakers.length; i++) {
            stakerReward[pl.stakers[i]] += reward;
        }
        policyRewardedBlock[pl.policyID] = block.number;
    }

    function giveOutReward() public {
        for (uint256 i = 0; i < policyIDList.length; i++) {
            policy storage pl = policyInfo[policyIDList[i]];
            uint256 reward = calcReward(pl);
            if (reward > 0) {
                for (uint256 j = 0; j < pl.stakers.length; j++) {
                    stakerReward[pl.stakers[j]] += reward;
                }
                if (block.number >= pl.end) {
                    pl.cancelBlock = pl.end;
                    policyRewardedBlock[pl.policyID] = pl.end;
                    return;
                }
                policyRewardedBlock[pl.policyID] = block.number;
            }
        }
    }

    function calcReward(policy memory _policy) private view returns (uint256) {
        if (_policy.begin > block.number || _policy.cancelBlock != 0) {
            return 0;
        }

        if (_policy.rewardBalance > 0 && _policy.stakers.length > 0) {
            uint256 period;
            uint256 rewarded = policyRewardedBlock[_policy.policyID];
            uint256 begin = rewarded > 0 ? rewarded : _policy.begin;
            if (begin > _policy.end) {
                return 0;
            }
            if (block.number >= _policy.end) {
                period = _policy.end.sub(begin);
            } else {
                period = block.number.sub(begin);
            }
            return period.mul(_policy.rewardBalance).div(_policy.end.sub(_policy.begin)).div(_policy.stakers.length);
        }
        return 0;
    }

    function claim(uint256 _amount) public {
        require(stakerReward[msg.sender] >= _amount, "insufficient balance");

        rewardToken.safeTransferFrom(address(this), msg.sender, _amount);
        stakerReward[msg.sender] -= _amount;
    }
}
