/**
 *Submitted for verification at BscScan.com on 2022-06-13
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface Iconf{
    function senator() external view returns(address);
    function poc() external view returns(address);
    function stEpoch() external view returns(uint);
    function voteEpoch() external view returns(uint);
    function offLine() external view returns(uint);
    function executEpoch() external view returns(uint);
}

interface Ipoc{
    function updateExecuter() external;
}

interface Isenator{
    function epochId() external view returns(uint);
    function executerId() external view returns(uint);
    function executerIndate() external view returns(uint);
    function getExecuter() external view returns(address);
    function isSenator(address) external view returns(bool);
}

contract Initialize {
    bool internal initialized;

    modifier init(){
        require(!initialized, "initialized");
        _;
        initialized = true;
    }
}

contract snapshoot is Initialize {
    address public conf;

    //快照集
    snapshootProposal[] public snapshoots;

    //提案状态:{等待，成功，失败}
    enum Result{PENDING, SUCCESS, FAILED}
    
    //快照提案（每天提案一次）
    struct snapshootProposal{
        uint epochId;                         //共识周期
        uint executerId;                      //执法者ID（第几任执法者）
        string prHash;                        //PR计算结果文件Hash
        string prId;                          //文件在IPFS上的ID
        address proposer;                     //提案人（执法者）
        uint proposalTime;                    //提案时间
        address[] assentors;                  //赞同者数量
        address[] unAssentors;                //反对者数量
        Result result;                        //共识结果
    }

    event SendSnapshootProposal(uint indexed executerId, address executer, string prHash, string prId);

    modifier onlyExecuter(){
        require(Isenator(Iconf(conf).senator()).getExecuter() == msg.sender, "access denied: only Executer");
        _;
    }

    modifier onlySentor(){
        require(Isenator(Iconf(conf).senator()).isSenator(msg.sender), "access denied: only senator");
        _;
    }

    modifier onlyPoc(){
        require(Iconf(conf).poc() == msg.sender, "access denied: only poc");
        _;
    }

   function initialize(address _conf) external init{
        conf = _conf;
    }
    
    //发起快照提案
    function sendSnapshootProposal(string memory _prHash, string memory _prId) external onlyExecuter{
        //require(isResolution(), "The latest proposal has no resolution");
        if (snapshoots.length != 0) require(snapshoots[snapshoots.length -1].proposer != msg.sender, "resubmit");
        
        uint _epochId = Isenator(Iconf(conf).senator()).epochId();
        uint _executerId = Isenator(Iconf(conf).senator()).executerId();
        address[] memory nilArray;
        snapshoots.push(snapshootProposal(
            _epochId,
            _executerId,
            _prHash,
            _prId,
            msg.sender,
            block.timestamp,
            nilArray,
            nilArray,
            Result.PENDING
        ));   
        snapshoots[snapshoots.length -1].assentors.push(msg.sender);

        emit SendSnapshootProposal(_executerId, msg.sender, _prHash, _prId);
    }
    
     //获取最新提案
    function latestSnapshootProposal() external view returns(uint epochId, uint executerId, string memory prHash, string memory prId, address proposer, uint proposalTime, uint result){
        snapshootProposal memory sp = snapshoots[snapshoots.length -1];
        return(sp.epochId, sp.executerId, sp.prHash, sp.prId, sp.proposer, sp.proposalTime, uint(sp.result));
    }

    function latestSuccesSnapshootProposal() external view returns(uint epochId, uint executerId, string memory prHash, string memory prId, address proposer, uint proposalTime, uint result){
        snapshootProposal memory sp;
        for(uint i = snapshoots.length -1; i >= 0; i--){
            if (snapshoots[i].result == Result.SUCCESS){
                sp = snapshoots[i];
                break;
            } 
        }
        return(sp.epochId, sp.executerId, sp.prHash, sp.prId, sp.proposer, sp.proposalTime, uint(sp.result));
    }

    //表决提案
    function vote(bool v) external onlySentor{
        require(snapshoots.length != 0, "No snapshootProposal");
        require(!isResolution(), "Reached a consensus");

        for (uint i=0; i < snapshoots[snapshoots.length-1].assentors.length; i++){
                require(snapshoots[snapshoots.length-1].assentors[i] != msg.sender,  "multiple voting");
            }
        for (uint i=0; i < snapshoots[snapshoots.length-1].unAssentors.length; i++){
                require(snapshoots[snapshoots.length-1].unAssentors[i] != msg.sender,  "multiple voting");
            }

        if(v) {
            snapshoots[snapshoots.length-1].assentors.push(msg.sender);
            if (snapshoots[snapshoots.length-1].assentors.length >= Iconf(conf).offLine()) snapshoots[snapshoots.length-1].result = Result.SUCCESS;
        }else{
            snapshoots[snapshoots.length-1].unAssentors.push(msg.sender);
            if (snapshoots[snapshoots.length-1].unAssentors.length >= Iconf(conf).offLine()) {
                snapshoots[snapshoots.length-1].result = Result.FAILED;
                Ipoc(Iconf(conf).poc()).updateExecuter();
                }
        }
    }

    //一票否决
    function veto() external onlyPoc{
        if (snapshoots.length != 0) snapshoots[snapshoots.length-1].result = Result.FAILED;
    }


    //最新提案是否已完成表决
    function isResolution() public view returns(bool){
         if (snapshoots.length == 0 || snapshoots[snapshoots.length-1].result != Result.PENDING) {
             return true;
         }else{
             return false;
         }
    }

    //执法者是否违规
    function  isOutLine() external view returns(bool){
        if (     //未按时提交快照
                (
                    (snapshoots.length == 0 || snapshoots[snapshoots.length -1].executerId != Isenator(Iconf(conf).senator()).executerId()) 
                    && 
                    block.timestamp + Iconf(conf).executEpoch() - Iconf(conf).stEpoch() > Isenator(Iconf(conf).senator()).executerIndate()
                ) ||
                //超时未达成共识
                (
                    snapshoots[snapshoots.length -1].result == Result.PENDING 
                    &&
                    block.timestamp > snapshoots[snapshoots.length -1].proposalTime + Iconf(conf).voteEpoch()
                )
        ){
            return true;
        }else{
            return false;
        }
    }
}