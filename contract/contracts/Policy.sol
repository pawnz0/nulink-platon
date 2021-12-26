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
        uint256 cancelBlock;
        address[] stakers;
    }
    
    //@policyIDList is user policy id list user can del  .
    mapping(address=> uint256[])  public policyIDList; 
    mapping(uint256 => policy) public policyInfo;
    mapping(address => mapping(uint256 => uint256)) public stakerInBlock; // user => pid => inBlock
    mapping(address => mapping(uint256 => uint256)) public stakerHavestBlock; // user => pid => inBlock
    mapping(uint256 => address[]) public policyStakerList;
    mapping(uint256 => mapping(address => bool)) public isPolicyStaker;
    
    
    modifier onlyPolicyStaker(uint256 _pid){
        require(isPolicyStaker[_pid][msg.sender],"only policy staker");
        _;
    }
    
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
            cancelBlock : 0,
            stakers : _stakerAddress
        });
        
        
        for(uint256 i=0; i< _stakerAddress.length; i++){
            policyStakerList[pID].push(_stakerAddress[i]);
            isPolicyStaker[pID][_stakerAddress[i]] = true;
        }
        
        
        
    }
    
    /**
     * @dev cancelPolicy any user can cancel ther policy 
     */
    function cancelPolicy(uint256 _pid) public{
        policy storage pl = policyInfo[_pid];
        require(pl.creater == msg.sender,"this create not right");
        require(pl.cancelBlock == 0,"alread canceled ");
        uint256 endblock = block.number > pl.end ? pl.end : block.number;
        
        uint256 calcRewardBalance = calcReward(_pid);
        
        pl.cancelBlock = endblock;
        
        if(pl.rewardBalnce >= calcRewardBalance){
            rewardToken.safeTransfer(msg.sender,pl.rewardBalnce.sub(calcRewardBalance));
        }
    }

    
    /**
     * @dev joinPolicy staker need join policy can get reward 
     */
    function joinPolicy(uint256 _pid) public onlyPolicyStaker(_pid){
        policy storage pl = policyInfo[_pid];
        require(pl.cancelBlock == 0,"policy is cancel");
        require(pl.creater != address(0),"policy not creater");
        require(pl.end > block.number,"plocy is end");
        
        stakerInBlock[msg.sender][_pid] = block.number;
        stakerHavestBlock[msg.sender][_pid] = block.number;
    }
    
    /**
     * @dev harvest staker can havest reward  
     */
    function harvest(uint256 _pid) public onlyPolicyStaker(_pid){
        
    }
    
    function checkStaker(address[] memory stakerAddress) view internal returns(bool){
        for(uint256 i=0; i< stakerAddress.length; i++){
            if(!staking.isStaker(stakerAddress[i])){
                return false;
            }
        }
        return true;
    }
    
    /**
     * @dev calcReward Calculate how much reward needs to be spent based on the current block  
     */
    function calcReward(uint256 _pid) public view returns(uint256 castReward) {
        policy memory pl = policyInfo[_pid];
        uint256 thisEndBlock = block.number;
        if(pl.cancelBlock != 0){
            return 0;
        }
        if(pl.rewardBalnce > 0){
            if(pl.stakers.length > 0){
                uint256 blockReward = pl.rewardBalnce.div(pl.end.sub(pl.begin)).div(pl.stakers.length);
                
                uint256 inBlock;
                for(uint256 i=0; i< policyStakerList[_pid].length;i++){
                    inBlock = stakerInBlock[policyStakerList[_pid][i]][_pid];
                    
                    if(thisEndBlock > inBlock && inBlock != 0){
                        castReward = castReward.add(thisEndBlock.sub(inBlock).mul(blockReward));
                    }
                    
                }
            }
           
        }
    }
    
    
}