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
    
    uint256  public pID; //this is PID
    IERC20  public rewardToken;
    
    struct policy {
        uint256 policyid;
        address creater;
        uint256 rewardBalnce; //
        uint256 begin;
        uint256 end;
        address[] stakers;
    }
    
    //@policyIDList is user policy id list user can del  .
    mapping(address=> uint256[])  public policyIDList; 
    mapping(uint256 => policy) public policyInfo;
    mapping(address => mapping(uint256 => uint256)) public stakerInBlock; // user => pid => inBlock
    
    
    constructor(IStaking _staking,IERC20 _rewardToken) {
        //require(_staking.isContract(),"only staking is controller");
        require(address(_rewardToken).isContract(),"only reward token is controller" );
        staking = _staking;
        rewardToken = _rewardToken;
    }
    
    /**
     * @dev createPolicy any user can create ther policy 
     */
    function createPolicy(address[] memory _stakerAddress,uint256 _rewardBalance,uint256 _begin,uint256 _end) public {
        //check staker 
        require(checkStaker(_stakerAddress),"staker address not staker");
        require(_end > _begin && _begin >= block.number,"create begin and end is illegal");
        require(_rewardBalance > 0,"reward balance must big zero");
        
        
        pID+= pID;
        
        rewardToken.safeTransferFrom(msg.sender,address(this),_rewardBalance);
        
        policyInfo[pID] = policy({
            policyid : pID,
            creater : msg.sender,
            rewardBalnce : _rewardBalance,
            begin : _begin,
            end : _end,
            stakers : _stakerAddress
        });
    }
    
    /**
     * @dev cancelPolicy any user can cancel ther policy 
     */
    function cancelPolicy(uint256 _pid) public{
        
    }
    
    /**
     * @dev joinPolicy staker need join policy can get reward 
     */
    function joinPolicy(uint256 _pid) public{
        
    }
    
    /**
     * @dev harvest staker can havest reward  
     */
    function harvest(uint256 _pid) public{
        
    }
    
    function checkStaker(address[] memory stakerAddress) view internal returns(bool){
        for(uint256 i=0; i< stakerAddress.length; i++){
            if(!staking.isStaker(stakerAddress[i])){
                return false;
            }
        }
        return true;
    }
    
    
    
    
}