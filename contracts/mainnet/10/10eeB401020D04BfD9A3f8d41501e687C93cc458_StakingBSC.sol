/**
 *Submitted for verification at BscScan.com on 2023-03-01
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function balanceOf(address account) view external returns (uint256);
    function decimals() view external returns (uint256);

}

contract StakingBSC {

    bool pause;
    uint time;
    uint endTime;
    uint32 txId;
    uint32 constant months = 2629743;
    uint8 constant idNetwork = 56;
    mapping(string => address) tokens;

    address public owner;
    address payable public marketingAddress = payable(0xC3b8A652e59d59A71b00808c1FB2432857080Ab8);

    modifier onlyOwner() {
        require(msg.sender == owner,"You not owner");
        _;
    }

    struct Participant{
        address sender;
        uint timeLock;
        string addrCN;
        address token;
        uint sum;
        uint timeUnlock;
        bool staked;
    }


    event staked(
        address sender,
        uint value,
        uint8 countMonths,
        string walletCN,
        address token,
        uint time,
        uint timeUnlock,
        uint32 txId,
        uint8 procentage,
        uint8 networkID,
        uint _block
    );

    event unlocked(
        address sender,
        uint sumUnlock,
        uint32 txID

    );

    constructor(){
        owner = msg.sender;
    }


    Participant participant;

    // information Participant
    mapping(address => mapping(uint32 => Participant)) timeTokenLock;

    mapping(uint32 => Participant) checkPart;


    function pauseLock(bool answer) external onlyOwner returns(bool){
        pause = answer;
        return pause;
    }

    function setMarketingAddress(address _addy) external onlyOwner {
    marketingAddress = payable(_addy);
    }


    //@dev calculate months in unixtime
    function timeStaking(uint _time,uint8 countMonths) internal pure returns (uint){
        require(
            countMonths >=3,
             "Minimal month 3"
             );
        require(
            countMonths <=24,
             "Maximal month 24"
             );

        return _time + (months * countMonths);
    }

    function seeAllStaking(address token) view public returns(uint){
        return IERC20(token).balanceOf(address(this));
    }


    function stake(uint _sum,uint8 count,string memory addrCN,uint8 procentage,string memory pairName) public  returns(uint32) {
        require(
            procentage <= 100,
            "Max count procent 100");
        require(
            !pause,
            "Staking paused"
            );
        require(
            getPair(pairName) != address(0),
            "Not this pair"
            );

        uint _timeUnlock = timeStaking(block.timestamp,count);
        //creating a staking participant
        participant = Participant(
            msg.sender,
            block.timestamp,
            addrCN,getPair(pairName),
            _sum,
            _timeUnlock,
            true
            );

        //identifying a participant by three keys (address, transaction ID, token address)
        timeTokenLock[msg.sender][txId] = participant;
        checkPart[txId] = participant;

        IERC20(tokens[pairName]).transferFrom(
            msg.sender,
            address(this),
            _sum
            );


        emit staked(
            msg.sender,
            _sum,
            count,
            addrCN,
            getPair(pairName),
            block.timestamp,
            _timeUnlock,
            txId,
            procentage,
            idNetwork,
            block.number
            );

        txId ++;
        return txId -1;
    }

    function claimFund(uint32 _txID) external {
        require(
            block.timestamp >= timeTokenLock[msg.sender][_txID].timeUnlock,
           "The time has not yet come" 
           );
        require(
            timeTokenLock[msg.sender][_txID].staked,
            "The steak was taken"
            );
        require(
            msg.sender == timeTokenLock[msg.sender][_txID].sender,
            "You are not a staker"
            );
        require(
            timeTokenLock[msg.sender][_txID].timeLock != 0
            );


        IERC20(timeTokenLock[msg.sender][_txID].token).transfer(
            msg.sender,
            timeTokenLock[msg.sender][_txID].sum
            );
        

        timeTokenLock[msg.sender][_txID].staked = false;
        checkPart[_txID].staked = false;
        
        emit unlocked(
            msg.sender,
            timeTokenLock[msg.sender][_txID].sum,
            _txID
            );
    }

    function seeStaked (uint32 txID)
        view public returns
        (
        uint timeLock,
        string memory addrCN,
        uint sum,
        uint timeUnlock,
        bool _staked
        )
        {
        return (checkPart[txID].timeLock,
                checkPart[txID].addrCN,
                checkPart[txID].sum,
                checkPart[txID].timeUnlock,
                checkPart[txID].staked);
    }



    function withdraw(address tokenAddr, uint _amount) external onlyOwner {
        
        IERC20(tokenAddr).transfer(
            msg.sender,
            _amount
            );
    }

    function addPairV2(string memory tokenName, address tokenAddr) external onlyOwner{
        tokens[tokenName] = tokenAddr;
    }

    function getPair(string memory pair) view public returns (address){
        return tokens[pair];
    }
}