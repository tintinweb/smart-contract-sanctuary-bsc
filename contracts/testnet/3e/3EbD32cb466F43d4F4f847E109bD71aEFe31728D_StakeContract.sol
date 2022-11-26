// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

import "./IERC20.sol";
import "./Owner.sol";
import "./ReentrancyGuard.sol";
import "./ERC1155Holder.sol";

interface IERC1155{
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;
}

interface Referrals{
    function addReward1(address _referredAccount, uint256 _amount) external returns(uint256);
    function addReward2(address _referredAccount, uint256 _amount) external returns(uint256);
}

contract StakeContract is Owner, ReentrancyGuard, ERC1155Holder {

    // nfts contract address 
    address public nfts;

    // the token address to be used for pay rewards
    address public rewardToken;

    // referrals contract address 
    address public referrals;

    // address with balance to be used to pay rewards
    address public rewardWallet;

    // minimum stake time in seconds
    uint256 public MST;

    // the Stake
    struct Stake {
        // stake Type
        uint256 stakeTypeIndex;
        // opening timestamp
        uint256 startDate;
        // amount staked
    	uint256 amount;
        // is active or not
    	bool active;
    }

    // the StakeType
    struct StakeType {
        uint256 tokenId;
        uint256 apy; // Annual Percentage Yield (1=1%)
        uint256 LVLXUnitPrice;
    	bool status; // true=actived, false=disabled
    }

    // stakes of address
    mapping(address => Stake[10]) public stakesOf;

    // stake Type List
    StakeType[20] public stakeTypeList;

    event Set_TokenContracts(
        address rewardToken,
        address nfts,
        address referrals
    );

    event Set_RewardWallet(
        address rewardWallet
    );

    event Set_MST(
        uint256 MST
    );

    event Set_StakeType(
        uint256 index,
        uint256 indexed tokenId,
        uint256 apy,
        uint256 LVLXUnitPrice,
        bool status
    );

    event AddedStake(
        uint256 stakeTypeIndex,
        uint256 indexed tokenId,
        uint256 startDate,
        uint256 amount,
        address indexed ownerStake
    );

    event WithdrawStake(
        uint256 _withdrawType,
        uint256 stakeTypeIndex,
        uint256 indexed tokenId,
        uint256 startDate,
        uint256 withdrawDate,
        uint256 interest,
        uint256 amount,
        address indexed ownerStake
    );

    constructor(address _rewardToken, address _nfts, address _referrals) {
        setTokenContracts(_rewardToken, _nfts, _referrals);
        setRewardWallet(getOwner());
        setMST(2592000); // 30 days in seconds

        uint256 mulByDec = 10**18;
        setStakeType(0, 1, 84, 5000*mulByDec, true); // recreacion y turismo 7%/month = 84%/year
        setStakeType(1, 2, 96, 10000*mulByDec, true); // transporte 8%/month = 96%/year
        setStakeType(2, 3, 108, 20000*mulByDec, true); // hoteleria 9%/month = 108%/year
    }

    function setTokenContracts(address _rewardToken, address _nfts, address _referrals) public isOwner {
        rewardToken = _rewardToken;
        nfts = _nfts;
        referrals = _referrals;
        emit Set_TokenContracts(_rewardToken, _nfts, _referrals);
    }

    function setRewardWallet(address _newVal) public isOwner {
        rewardWallet = _newVal;
        emit Set_RewardWallet(_newVal);
    }

    function setMST(uint256 _newVal) public isOwner {
        MST = _newVal;
        emit Set_MST(_newVal);
    }

    function setStakeType(uint256 _index, uint256 _tokenId, uint256 _apy, uint256 _LVLXUnitPrice, bool _status) public isOwner {
        require(_index >= 0 && _index <= 19, "_index must be a number between 0 and 19");
        stakeTypeList[_index].tokenId = _tokenId;
        stakeTypeList[_index].apy = _apy;
        stakeTypeList[_index].LVLXUnitPrice = _LVLXUnitPrice;
        stakeTypeList[_index].status = _status;
        emit Set_StakeType(_index, _tokenId, _apy, _LVLXUnitPrice, _status);
    }

    function calculateInterest(uint256 _stakeTypeIndex, uint256 _stakeStartDate, uint256 _stakeAmount) public view returns (uint256) {
        uint256 apy = stakeTypeList[_stakeTypeIndex].apy;
        uint256 LVLXUnitPrice = stakeTypeList[_stakeTypeIndex].LVLXUnitPrice;

        // APY per year = amount * APY / 100
        uint256 interest_per_year = ((_stakeAmount*LVLXUnitPrice) * apy) / 100;

        // number of seconds since opening date
        uint256 num_seconds = block.timestamp - _stakeStartDate;

        // calculate interest by a rule of three
        //  seconds of the year: 31536000 = 365*24*60*60
        //  interest_per_year   -   31536000
        //  interest            -   num_seconds
        //  interest = num_seconds * interest_per_year / 31536000
        return (num_seconds * interest_per_year) / 31536000;
    }

    function getIndexToCreateStake(address _account) private view returns (uint256) {
        uint256 index = 10;
        for(uint256 i=0; i<stakesOf[_account].length; i++){
            if(!stakesOf[_account][i].active){
                index = i;
            }
        }
        // if (index < 10)  = limit not reached
        // if (index == 10) = limit reached
        return index; 
    }

    // anyone can create a stake
    function createStake(uint256 _stakeTypeIndex, uint256 _amount) external {
        require(stakeTypeList[_stakeTypeIndex].status, "_stakeTypeIndex is not valid or is not active");
        uint256 index = getIndexToCreateStake(msg.sender);
        require(index < 10, "stakes limit reached");
        uint256 tokenId = stakeTypeList[_stakeTypeIndex].tokenId;
        // store the tokens of the user in the contract
        // requires approve
        IERC1155(nfts).safeTransferFrom(msg.sender, address(this), tokenId, _amount, "");
        // create the stake
        stakesOf[msg.sender][index] = Stake(_stakeTypeIndex, block.timestamp, _amount, true);
        emit AddedStake(_stakeTypeIndex, tokenId, block.timestamp, _amount, msg.sender);
    }

    function withdrawStake(uint256 _arrayIndex, uint256 _withdrawType) external nonReentrant { // _withdrawType (1=normal withdraw, 2=withdraw only rewards)
        require(_withdrawType>=1 && _withdrawType<=2, "invalid _withdrawType");
        // Stake should exists and opened
        require(_arrayIndex < stakesOf[msg.sender].length, "Stake does not exist");
        Stake memory stk = stakesOf[msg.sender][_arrayIndex];
        require(stk.active, "This stake is not active");
        require((block.timestamp - stk.startDate) >= MST, "the minimum stake time has not been completed yet");
        uint256 tokenId = stakeTypeList[stk.stakeTypeIndex].tokenId;

        // get the interest
        uint256 interest = calculateInterest(stk.stakeTypeIndex, stk.startDate, stk.amount);
        interest = interest - Referrals(referrals).addReward2(msg.sender, interest);

        // transfer the interes from rewardWallet, it has to have enough funds approved
        IERC20(rewardToken).transferFrom(rewardWallet, msg.sender, interest);

        if(_withdrawType == 1){
            // transfer the NFTs from the contract itself
            IERC1155(nfts).safeTransferFrom(address(this), msg.sender, tokenId, stk.amount, "");
            // stake closing
            delete stakesOf[msg.sender][_arrayIndex];
        }else{
            // restart stake
            stakesOf[msg.sender][_arrayIndex].startDate = block.timestamp;
        }

        emit WithdrawStake(_withdrawType, stk.stakeTypeIndex, tokenId, stk.startDate, block.timestamp, interest, stk.amount, msg.sender);
    }

    function getStakesOf(address _account) external view returns(uint256[] memory, uint256[] memory, uint256[] memory, uint256[] memory, bool[] memory){
        uint256 stakesLength = stakesOf[_account].length;
        uint256[] memory tokenIdList = new uint256[](stakesLength);
        uint256[] memory startDateList = new uint256[](stakesLength);
        uint256[] memory amountList = new uint256[](stakesLength);
        uint256[] memory interestList = new uint256[](stakesLength);
        bool[] memory activeList = new bool[](stakesLength);

        for(uint256 i=0; i<stakesLength; i++){
            Stake memory stk = stakesOf[_account][i];
            tokenIdList[i] = stakeTypeList[stk.stakeTypeIndex].tokenId;
            startDateList[i] = stk.startDate;
            amountList[i] = stk.amount;
            interestList[i] = calculateInterest(stk.stakeTypeIndex, stk.startDate, stk.amount);
            activeList[i] = stk.active;
        }

        return (tokenIdList, startDateList, amountList, interestList, activeList);
    }
}