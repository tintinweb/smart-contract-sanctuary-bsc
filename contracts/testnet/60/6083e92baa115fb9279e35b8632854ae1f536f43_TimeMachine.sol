//SPDX-License-Identifier:MIT
pragma solidity ^0.8.16;

import "./Math.sol";
import "./Address.sol";
import "./ERC20.sol";

contract TimeMachine is Context, ERC20("Water Test", "WT3") {
    using Math for uint256;
    using Address for address;

    uint256 public constant MAX_TOTAL_SUPPLY = 21*10**6*10**18;

    uint256 public constant DECAY_YEARS = 4;
    uint256 public constant DAYS_IN_YEAR = 365;
    uint256 public constant SECONDS_IN_DAY = 3_600 * 24;
    uint256 public constant BLOCK_IN_FOUR_YEAR = 1460;

    uint256 public constant BLOCK_START_PRODUCTION_TIMA = 7_200;
    
    uint256 public constant EAA_PM_MAX= 1_000;
    uint256 public constant EAA_RANK_STEP = 5_000;

    uint256 public constant TCP_MIN = 1000;
    uint256 public constant TCP_DECAY_NUMBER = 8;
    uint256 public constant TCP_DECAY_VALUE = 200;
    
    //uint256 public immutable genesisTs;
    uint256 public  genesisTs;
    uint256 public globalRank=1;
    
    uint256 public totalClaimed;

    address private _withdrawOnlyOwner;

    string public constant AUTHORS = "Nakamoto Water";

    constructor() {
        //genesisTs = block.timestamp-3600*24*5;
        _withdrawOnlyOwner=msg.sender;
    }
    
    function setGenesisTs(uint256 day) public{
        genesisTs = block.timestamp-3600*24*day;
    }

    struct MachineInfo{
        uint256 rank;
        //Early Adopter Amplification
        uint256 eaa;
        //Computing power bonus
        uint256 cpb;
        //total computing power one machine
        uint256 tcp;
        //claim mint reward number
        uint256 cmrn;
        uint256 lastInBlock;
        uint256 lasttime;
    }
    mapping(address => MachineInfo) public userMachineInfos;
    mapping(address => uint256) public userBurns;
    mapping(uint256 => uint256) public everyBlockTCP;
    
    /**
     * @dev returns EAA
     * div(1000)
     */
    function _calculateEAA() private view returns (uint256) {
        uint256 decrease = globalRank.div(EAA_RANK_STEP);
        if (decrease >= EAA_PM_MAX) return 0;
        return EAA_PM_MAX.sub(decrease);
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
        uint256 rankMod = rank.mod(10);
        if(rankMod==1||rankMod==2||rankMod==7||rankMod==8) return rankMod*100;
        return 0;
    }

    /**
     * @dev returns calculate current block
     */
    function _calculateCurrentBlock(uint256 currentTime) private view returns (uint256) {
        return currentTime.sub(genesisTs).div(SECONDS_IN_DAY);
    }

    /**
     * @dev returns calculate user Mined
     */
    function _calculateUserMined(uint256 userTcp,uint256 userInBlock,uint256 userOutBlock) public view returns (uint256) {
        uint256 userMined;
        uint256 upBlockTCP=everyBlockTCP[userInBlock];
        for(uint256 i=userInBlock;i<userOutBlock;i++)
        {
            uint256 userBlockTCP=everyBlockTCP[i];
            if(userBlockTCP==0) userBlockTCP=upBlockTCP;
            userMined+=_calculateOneBlockMined(i).mul(userTcp).div(userBlockTCP);
            upBlockTCP=userBlockTCP;
        }
        return userMined;
    }

    /**
     * @dev returns calculate One Block Mined
     */
    function _calculateOneBlockMined(uint256 blockNumber) private pure returns (uint256) {
        if(blockNumber<BLOCK_IN_FOUR_YEAR.mul(1)) return BLOCK_START_PRODUCTION_TIMA.mul(1e18);
        if(blockNumber>=BLOCK_IN_FOUR_YEAR.mul(1) && blockNumber<BLOCK_IN_FOUR_YEAR.mul(2)) return BLOCK_START_PRODUCTION_TIMA.mul(1e18).div(2);
        if(blockNumber>=BLOCK_IN_FOUR_YEAR.mul(2) && blockNumber<BLOCK_IN_FOUR_YEAR.mul(3)) return BLOCK_START_PRODUCTION_TIMA.mul(1e18).div(4);
        if(blockNumber>=BLOCK_IN_FOUR_YEAR.mul(3) && blockNumber<BLOCK_IN_FOUR_YEAR.mul(4)) return BLOCK_START_PRODUCTION_TIMA.mul(1e18).div(8);
        if(blockNumber>=BLOCK_IN_FOUR_YEAR.mul(4) && blockNumber<BLOCK_IN_FOUR_YEAR.mul(5)) return BLOCK_START_PRODUCTION_TIMA.mul(1e18).div(16);
        if(blockNumber>=BLOCK_IN_FOUR_YEAR.mul(5) && blockNumber<BLOCK_IN_FOUR_YEAR.mul(6)) return BLOCK_START_PRODUCTION_TIMA.mul(1e18).div(32);
        if(blockNumber>=BLOCK_IN_FOUR_YEAR.mul(6) && blockNumber<BLOCK_IN_FOUR_YEAR.mul(7)) return BLOCK_START_PRODUCTION_TIMA.mul(1e18).div(64);
        if(blockNumber>=BLOCK_IN_FOUR_YEAR.mul(7) && blockNumber<BLOCK_IN_FOUR_YEAR.mul(8)) return BLOCK_START_PRODUCTION_TIMA.mul(1e18).div(128);
        if(blockNumber>=BLOCK_IN_FOUR_YEAR.mul(8) && blockNumber<BLOCK_IN_FOUR_YEAR.mul(9)) return BLOCK_START_PRODUCTION_TIMA.mul(1e18).div(256);
        if(blockNumber>=BLOCK_IN_FOUR_YEAR.mul(9) && blockNumber<BLOCK_IN_FOUR_YEAR.mul(9).add(1214)) return BLOCK_START_PRODUCTION_TIMA.mul(1e18).div(512);
        return 0;
    }

    /**
     * @dev returns total Mined
     */
    // function getTotalMined() external view returns (uint256) {
    //     uint256 totalMined;
    //     uint256 currentBlock=_calculateCurrentBlock(block.timestamp);
    //     return totalMined;
    // }

    event StartMachine(address indexed user,uint256 rank,uint256 tcp);
    event MintClaimed(address indexed user, uint256 inBlock,uint256 outBlock,uint256 rewardAmount);
    
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
        //uint256 lastInBlock=_calculateCurrentBlock(block.timestamp);
        uint256 lastInBlock=0;
        MachineInfo memory machineInfo = MachineInfo({
            rank: globalRank,
            eaa: eaa,
            cpb: cpb,
            tcp: tcp,
            cmrn: 1,
            lastInBlock:lastInBlock,
            lasttime:block.timestamp
        });
        userMachineInfos[_msgSender()] = machineInfo;
        emit StartMachine(_msgSender(),globalRank,tcp);
        globalRank++;
        //update block TCP
        everyBlockTCP[lastInBlock]=everyBlockTCP[lastInBlock].add(tcp);
        return true;
    }

    /**
     * @dev returns TCP
     */
    function _calculateTCP(uint256 tcp,uint256 cmrn) private pure returns (uint256) {
        if(cmrn.mod(TCP_DECAY_NUMBER)==0) tcp-=TCP_DECAY_VALUE;
        if(tcp<=TCP_MIN) return TCP_MIN;
        return tcp;
    }

    /**
     * @dev calculates gross Mint Reward
     */
    function getGrossReward(uint256 tcp,uint256 inBlock,uint256 outBlock) public view returns (uint256) {
       return _calculateUserMined(tcp,inBlock,outBlock);
    }

    /**
     * @dev claim Mint Reward
     */
    function claimMintReward() external returns(bool success) {
        MachineInfo memory machineInfo = userMachineInfos[_msgSender()];
        require(machineInfo.rank > 0, "TIMA: No mint exists");
        //require(block.timestamp > machineInfo.lasttime.add(SECONDS_IN_DAY), "TIMA: wait at least one day");
        
        
        uint256 outBlock=_calculateCurrentBlock(block.timestamp);
        uint256 lasttime=block.timestamp;
        if(outBlock.sub(machineInfo.lastInBlock)>=365)
        {
            outBlock=machineInfo.lastInBlock.add(365);
            lasttime+=SECONDS_IN_DAY.mul(365);
        }
        
        //calculate reward and mint tokens
        uint256 rewardAmount = _calculateUserMined(
            machineInfo.tcp,
            machineInfo.lastInBlock,
            outBlock
        );
        if(rewardAmount>0) {
            _mint(_msgSender(), rewardAmount);
            emit MintClaimed(_msgSender(), machineInfo.lastInBlock , outBlock , rewardAmount);
            uint256 newTcp=_calculateTCP(machineInfo.tcp,machineInfo.cmrn);
            //update every block TCP
            everyBlockTCP[outBlock]+=newTcp;
            //update tcp
            userMachineInfos[_msgSender()].tcp=newTcp;
            //update tcp cmrn
            userMachineInfos[_msgSender()].cmrn++;
            //update lastInBlock
            userMachineInfos[_msgSender()].lastInBlock=outBlock;
            //update lasttime
            userMachineInfos[_msgSender()].lasttime=lasttime;
            //update total claim reward
            totalClaimed+=rewardAmount;
            return true;
        }
        return false;
    }

    /**
     * @dev burns TIMA tokens
     */
    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
        userBurns[_msgSender()] += amount;
    }

    receive() external payable{}

    modifier withdrawOnlyOwner(){
        require(msg.sender==_withdrawOnlyOwner,"TIMA: not withdrawOwner!");
        _;
    }

    function withdrawEth() public withdrawOnlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function withdrawToken(address _token,uint256 amount) public withdrawOnlyOwner {
        IERC20(_token).transfer(msg.sender, amount);
    }
}