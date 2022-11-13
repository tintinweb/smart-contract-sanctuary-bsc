//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import "./Math.sol";
import "./Address.sol";
import "./ERC20.sol";

contract TimeMachine is Context, ERC20("Water Test", "WT") {
    using Math for uint256;
    using Address for address;

    uint256 public constant SECONDS_IN_DAY = 3_600 * 24;
    uint256 public constant DAYS_IN_YEAR = 365;
    uint256 public constant BLOCK_PRODUCTION_TIME = 600;
    uint256 public constant BLOCK_START_PRODUCTION_TIMA = 50;
    uint256 public constant DECAY_YEARS = 4;

    uint256 public constant EAA_PM_MAX= 1_000;
    uint256 public constant EAA_RANK_STEP = 5_000;

    uint256 public constant TCP_DECAY_NUMBER = 8;

    uint256 public immutable genesisTs;
    uint256 public globalRank=1;
    
    uint256 public totalClaimed;
    uint256 public totalComputingPower;

    address private _withdrawOnlyOwner;

    string public constant AUTHORS = "Nakamoto Water";

    constructor() payable {
        genesisTs = block.timestamp;
        _withdrawOnlyOwner=msg.sender;
    }
    struct MachineInfo{
        uint256 rank;
        //Early Adopter Amplification
        uint256 eaa;
        //Computing power bonus
        uint256 cpb;
        //total computing power
        uint256 tcp;
        //claim mint reward number
        uint256 cmrn;
        uint256 lasttime;
    }
    mapping(address => MachineInfo) public userMachineInfos;
    
    /**
     * @dev returns EAA
     * div(1000)
     */
    function _calculateEAA() private view returns (uint256) {
        uint256 decrease = globalRank / EAA_RANK_STEP;
        if (decrease > EAA_PM_MAX) return 0;
        return EAA_PM_MAX - decrease;
    }

    /**
     * @dev returns Current EAA
     */
    function getCurrentEAA() external view returns (uint256) {
       return _calculateEAA();
    }
    
    /**
     * @dev returns CPB
     * div(1000)
     */
    function _calculateCPB(uint256 rank) private pure returns (uint256) {
        uint256 cpb=0;
        uint256 rankMod = rank.mod(10);
        if(rankMod==7){
            cpb=700;
        }else if(rankMod==1){
            cpb=100;
        }else if(rankMod==8){
            cpb=800;
        }else if(rankMod==2){
            cpb=200;
        }
        return cpb;
    }

    /**
     * @dev returns calculate Mined
     */
    function _calculateMined(uint256 timestamp) private view returns (uint256) {
        uint256 lostTime=timestamp - genesisTs;
        uint256 decayNum=lostTime.div(DECAY_YEARS.mul(DAYS_IN_YEAR).mul(SECONDS_IN_DAY));
        uint256 totalMined;
        uint256 maxDecayNum=decayNum;
        if(decayNum>=9){
            maxDecayNum=9;
        }
        for(uint256 i=0;i<maxDecayNum;i++){
            uint256 decayNum2=2**i;
            totalMined+=DECAY_YEARS.mul(1e18).mul(DAYS_IN_YEAR).mul(SECONDS_IN_DAY).mul(BLOCK_START_PRODUCTION_TIMA).div(BLOCK_PRODUCTION_TIME).div(decayNum2);
        }
        lostTime-=maxDecayNum.mul(DECAY_YEARS).mul(DAYS_IN_YEAR).mul(SECONDS_IN_DAY);
        uint256 blockNum=lostTime.div(BLOCK_PRODUCTION_TIME);
        if(maxDecayNum==9){
            if(blockNum<=174720){
                totalMined+=blockNum.mul(1e18).mul(BLOCK_START_PRODUCTION_TIMA).div(2**maxDecayNum);
            }
            else{
                totalMined+=uint256(174720).mul(1e18).mul(BLOCK_START_PRODUCTION_TIMA).div(2**maxDecayNum);
            }
        }
        else{
            totalMined+=blockNum.mul(1e18).mul(BLOCK_START_PRODUCTION_TIMA).div(2**maxDecayNum);
        }
        return totalMined;
    }

    /**
     * @dev returns total Mined
     */
    function getTotalMined() external view returns (uint256) {
       return _calculateMined(block.timestamp);
    }

    event StartMachine(address indexed user,uint256 rank);
    event MintClaimed(address indexed user, uint256 rewardAmount);
    
    /**
     * @dev start machine
     */
    function startMachine() external returns(bool success) {
        require(userMachineInfos[_msgSender()].rank == 0, "TIMA: Machine already in progress");
        require(!_msgSender().isContract(), "Address: call to non-contract");
        // create and store new MachineInfo
        uint256 eaa=_calculateEAA();
        uint256 cpb=_calculateCPB(globalRank);
        uint256 tcp=eaa.add(cpb).add(2_000);
        MachineInfo memory machineInfo = MachineInfo({
            rank: globalRank,
            eaa: eaa,
            cpb: cpb,
            tcp: tcp,
            cmrn: 1,
            lasttime: block.timestamp
        });
        userMachineInfos[_msgSender()] = machineInfo;
        totalComputingPower+=tcp;
        emit StartMachine(_msgSender(),globalRank);
        globalRank++;
        return true;
    }

    /**
     * @dev returns CPB
     * div(1000)
     */
    function _calculateTCP(uint256 tcp,uint256 cmrn) private pure returns (uint256) {
        uint256 needSub=0;
        if(cmrn.mod(TCP_DECAY_NUMBER)==0){
            needSub=10**2;
        }
        uint256 subedTcp=tcp.sub(needSub);
        if(subedTcp<1000) return 1000;
        return subedTcp;
    }

    /**
     * @dev returns mint reward
     */
    function _calculateMintReward(uint256 lasttime,uint256 tcp) private view returns (uint256) {
        uint256 totalMined=_calculateMined(block.timestamp);
        uint256 hasMined=_calculateMined(lasttime);
        uint256 userCurrentMined=totalMined.sub(hasMined);
        if(userCurrentMined<=0) return 0;
        return userCurrentMined.mul(tcp).div(totalComputingPower);
    }

    /**
     * @dev calculates gross Mint Reward
     */
    function getGrossReward(uint256 lasttime,uint256 tcp) public view returns (uint256) {
       return _calculateMintReward(lasttime,tcp);
    }

    /**
     * @dev claim Mint Reward
     */
    function claimMintReward() external returns(bool success) {
        MachineInfo memory machineInfo = userMachineInfos[_msgSender()];
        require(machineInfo.rank > 0, "TIMA: No mint exists");
        require(block.timestamp.sub(BLOCK_PRODUCTION_TIME) > machineInfo.lasttime, "TIMA: no mining");
        
        // calculate reward and mint tokens
        uint256 rewardAmount = _calculateMintReward(
            machineInfo.lasttime,
            machineInfo.tcp
        );
        if(rewardAmount>0)
        _mint(_msgSender(), rewardAmount);

        emit MintClaimed(_msgSender(), rewardAmount);

        uint256 newtcp=_calculateTCP(machineInfo.tcp,machineInfo.cmrn);
        
        userMachineInfos[_msgSender()].tcp=newtcp;
        //update tcp cmrn
        userMachineInfos[_msgSender()].cmrn++;
        userMachineInfos[_msgSender()].lasttime=block.timestamp;
        //update total Computing Power
        totalComputingPower-=machineInfo.tcp.sub(newtcp);
        totalClaimed+=rewardAmount;
        return true;
    }

    modifier withdrawOnlyOwner(){
        require(msg.sender==_withdrawOnlyOwner,"TIMA: not withdrawOwner!");
        _;
    }

    function withdrawEth() public withdrawOnlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function withdrawToken(address _token) public withdrawOnlyOwner {
        IERC20(_token).transfer(msg.sender, address(this).balance);
    }
}