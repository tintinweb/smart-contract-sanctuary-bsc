// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ICartridgeSegaItems.sol";
import "./IPancakeV2Router.sol";
import "./MetaData.sol";

contract CartridgeSegonItemsMarket is ReentrancyGuard, Ownable {
    ICartridgeSegonItems public nfts;
    IERC20 public immutable stakingCoin;
    address public pancakeV2Pair;
    uint256 public delayExpirer = 23 hours;
    IPancakeV2Router02 public pancakeV2Router;
    mapping(uint256 => uint256) public tokenIdPrice;
    mapping(uint256 => uint16) public tokenIdStakingPercent;
    uint256 public tokensRewardReserved;
    mapping(address => UserMeta) public _addressUserMeta;

    uint256 public expireDays = 15 minutes;
    uint256 public duration = 60 seconds;
    bool public stakeEnabled = true;
    uint256 public priceMint = 0;

    modifier manager() {
        address sender = _msgSender();
        require(managers[sender] || sender == owner(), "u cant use this");
        _;
    }

    event Buy(
        uint256 time,
        address indexed addr,
        uint256 tokenId,
        address referral,
        uint256 value,
        uint256 timeExpirer
    );
    event Stake(uint256 time, address indexed addr, uint256 tokenId);

    event DistributeToken(
        uint256 time,
        address indexed addr,
        uint256 tokenId,
        address referral,
        uint256 timeExpirer
    );
    event RewardBNB(
        address indexed manager,
        uint256 time,
        string hash,
        uint256 totalReward
    );
    event RewardTokens(
        address indexed manager,
        uint256 time,
        uint256 totalReward
    );

    enum TokenUsage {
        P2Y,
        Stake,
        No
    }
    struct UserMeta {
        uint256 tokenId;
        uint256 dateExpirer;
        address referral;
        uint256 value;
        uint16 percent;
        TokenUsage usage;
        uint256 dateBuy;
        uint256 rateToken;
    }
    struct StakeInfo {
        uint256 startDate;
        uint256 lastClaimDate;
        uint16 percent;
        uint256 amount;
        uint256 wasPaid;
        bool isStaking;
        uint256 duration;
        uint256 endDate;
        uint256 rewardPerDuration;
    }
    mapping(address => StakeInfo) public userStake;
    address payable public liquidityWallet =
        payable(0xFfB06F9b182Ce293d647bB8532B443851134Ab8C);
    uint256 defaultRate = 316800000000000000000000;

    uint16 private liqPerc = 200;
    bool _fixRate = false;

    receive() external payable {}

    mapping(string => bool) public wasRewardPaidBNB;
    mapping(address => bool) managers;

    constructor(
        ICartridgeSegonItems _nfts,
        IERC20 _stakingCoin,
        IPancakeV2Router02 _router
    ) {
        nfts = _nfts;
        /// price in wei
        //   tokenIdPrice[0] = 4 * 1e17;
        // tokenIdPrice[1] = 238 * 1e16;
        // tokenIdPrice[2] = 5 * 1e18;

        tokenIdPrice[0] = 130000000000000;
        tokenIdPrice[1] = 660000000000000;
        tokenIdPrice[2] = 1660000000000000;

        /// percent staking
        tokenIdStakingPercent[0] = 600;
        tokenIdStakingPercent[1] = 900;
        tokenIdStakingPercent[2] = 1550;


        managers[0x058749a997C7361cFeea559A0258043EF1da60C5] = true;
        managers[0x78Ff39fE78B3447E3BaDf241b05b93bf2D46e350] = true;

        stakingCoin = _stakingCoin;

        pancakeV2Router = IPancakeV2Router02(_router);

        pancakeV2Pair = IPancakeV2Factory(pancakeV2Router.factory()).getPair(
            address(_stakingCoin),
            pancakeV2Router.WETH()
        );
    }

    function setDelayExpirer(uint256 _delay) external onlyOwner {
        delayExpirer = _delay;
    }

    function setCartridgeExpirer(address _addr, uint256 _date) external onlyOwner {
        require(_addressUserMeta[_addr].dateExpirer > 0 && _addressUserMeta[_addr].usage == TokenUsage.No, "cant set dateExpirer");
        _addressUserMeta[_addr].dateExpirer = _date;
    }

    function setTokenIdStakingPercent(uint256 _tokenId, uint16 _perc)
        external
        onlyOwner
    {
        tokenIdStakingPercent[_tokenId] = _perc;
    }

    function setLiquidityWallet(address _addr) external onlyOwner {
        liquidityWallet = payable(_addr);
    }

    function buy(uint256 _tokenId, address _referral)
        public
        payable
        nonReentrant
    {
        address sender = _msgSender();

        uint256 priceToken = tokenIdPrice[_tokenId];

        require(msg.value >= priceToken + priceMint, "not enough money to buy");

        address referral = _referral == address(0) ||
            _addressUserMeta[_referral].dateExpirer + delayExpirer >
            block.timestamp
            ? _referral
            : address(0);

        _distributeToken(_tokenId, sender, referral);

        uint256 val = msg.value - priceToken - priceMint;

        if (priceToken + priceMint < msg.value) payable(sender).transfer(val);

        uint256 liquidityWei = (priceToken * liqPerc) / 1000;

        if (liquidityWei > 0 && liquidityWallet != address(0)) {
            payable(liquidityWallet).transfer(liquidityWei);
        }

        emit Buy(
            block.timestamp,
            sender,
            _tokenId,
            referral,
            val,
            _addressUserMeta[sender].dateExpirer
        );
    }

    function distributeToken(
        uint256 _tokenId,
        address _to,
        address _referral
    ) public payable nonReentrant manager {
        address referral = _referral == address(0) ||
            _addressUserMeta[_referral].dateExpirer + delayExpirer >
            block.timestamp
            ? _referral
            : address(0);

        _distributeToken(_tokenId, _to, referral);

        emit DistributeToken(
            block.timestamp,
            _to,
            _tokenId,
            referral,
            _addressUserMeta[_to].dateExpirer
        );
    }

    function _distributeToken(
        uint256 _tokenId,
        address _to,
        address _referral
    ) private {
        uint256 priceToken = tokenIdPrice[_tokenId];

        require(tokenIdPrice[_tokenId] > 0, "_tokenId not exists");

        require(_viewReward(_to) == 0, "take your reward and try again");

        require(
            block.timestamp > _addressUserMeta[_to].dateExpirer,
            "token is still active"
        );

        nfts.mint(_to, _tokenId);

        _addressUserMeta[_to].tokenId = _tokenId;
        _addressUserMeta[_to].dateBuy = block.timestamp;
        _addressUserMeta[_to].dateExpirer = block.timestamp + expireDays;

        _addressUserMeta[_to].referral = _referral;
        _addressUserMeta[_to].usage = TokenUsage.No;
        _addressUserMeta[_to].percent = tokenIdStakingPercent[_tokenId];
        _addressUserMeta[_to].value = priceToken;
        _addressUserMeta[_to].rateToken = getRate();
    }

    function setDefaultRate(uint256 _val) external onlyOwner {
        defaultRate = _val;
    }

    function setLiqPerc(uint16 _perc) external onlyOwner {
        liqPerc = _perc;
    }

    function setPriceMint(uint256 _price) external onlyOwner {
        priceMint = _price;
    }

    function setExpireDays(uint256 _days) external onlyOwner {
        require(_days > 0, "_days == 0");
        expireDays = _days;
    }

    function setPriceToken(uint256 _tokenId, uint256 _price) external manager {
        tokenIdPrice[_tokenId] = _price;
    }

    function withdraw() external onlyOwner {
        require(address(this).balance > 0, "Contract has no money");
        payable(owner()).transfer(address(this).balance);
    }

    function calcs() public view returns (uint256) {
        if (stakingCoin.balanceOf(address(this)) > tokensRewardReserved)
            return stakingCoin.balanceOf(address(this)) - tokensRewardReserved;
        return 0;
    }

    function stake() public nonReentrant {
        require(stakeEnabled, "staking is disable");
        address user = _msgSender();
        UserMeta memory meta = _addressUserMeta[user];
        uint16 percent = tokenIdStakingPercent[meta.tokenId];
        require(percent > 0, "token id is not found");
        require(meta.usage == TokenUsage.No, "TokenUsage is selected");
        require(_viewReward(user) == 0, "take your reward and try again");
        uint256 amount = _showAmountTokens(meta.value);
        uint256 forReward = calcReward(amount, percent);

        require(calcs() > forReward, "not enough tokens for staking");

        require(
            meta.dateExpirer > block.timestamp + duration,
            "sorry, you cant stake yot nft now"
        );
        _addressUserMeta[user].percent = percent;
        _addressUserMeta[user].usage = TokenUsage.Stake;
        userStake[msg.sender] = StakeInfo(
            block.timestamp,
            block.timestamp,
            percent,
            amount,
            0,
            true,
            duration,
            meta.dateExpirer,
            forReward / ((meta.dateExpirer - block.timestamp) / duration)
        );
        tokensRewardReserved += forReward;
        emit Stake(block.timestamp, _msgSender(), meta.tokenId);
    }

    function showAmountRewardTokens() external view returns (uint256) {
        address user = _msgSender();
        UserMeta memory meta = _addressUserMeta[user];
        return _showAmountRewardTokens(meta.value, meta.percent);
    }

    function _showAmountRewardTokens(uint256 _value, uint16 percent)
        private
        view
        returns (uint256)
    {
        uint256 amount = _showAmountTokens(_value);
        return calcReward(amount, percent);
    }

    function _showAmountTokens(uint256 _value) private view returns (uint256) {
        return _calcAmountTokensWithDelta(_getTokenAmount(_value));
    }

    function getMaxAmountForStaking() external view returns (uint256) {
        address user = _msgSender();
        UserMeta memory meta = _addressUserMeta[user];
        uint256 percent = tokenIdStakingPercent[meta.tokenId];
        if (percent == 0 || meta.usage != TokenUsage.Stake) {
            return 0;
        }
        uint256 amount = _calcAmountTokensWithDelta(
            _getTokenAmount(meta.value)
        );
        uint256 forReward = calcReward(amount, percent);
        return forReward;
    }

    function GetTokenPrice(uint256 amount) public view returns (uint256) {
    IPancakeV2Pair pair2 = IPancakeV2Pair(pancakeV2Pair);
        (uint256 Res0, uint256 Res1, ) = pair2.getReserves();
        if (Res0 < Res1) {
            uint256 res0 = Res0 * (1e18);
            return ((amount * res0) / Res1); // return amount of token0 needed to buy token1
        } else {
            uint256 res1 = Res1 * (1e18);
            return ((amount * res1) / Res0); // return amount of token0 needed to buy token1
        }
    }

    function _getTokenAmount(uint256 weiAmount)
        internal
        view
        returns (uint256)
    {
        return (weiAmount * getRate()) / (10**18);
    }

    function getRate() public view returns (uint256) {
        return 1e36 / GetTokenPrice(1);
    }

    function _calcAmountTokensWithDelta(uint256 _amt)
        private
        view
        returns (uint256)
    {
        address user = _msgSender();
        UserMeta memory meta = _addressUserMeta[user];
        if (
            meta.dateExpirer != meta.dateBuy &&
            meta.dateExpirer > block.timestamp
        ) {
            return
                calcReward(
                    _amt,
                    ((meta.dateExpirer - block.timestamp) * 1000) /
                        (meta.dateExpirer - meta.dateBuy)
                );
        }
        return 0;
    }

    function calcReward(uint256 _amount, uint256 _percent)
        public
        pure
        returns (uint256)
    {
        return (_amount * _percent) / 1000;
    }

    function getReward() external nonReentrant {
        address sender = msg.sender;
        require(
            _addressUserMeta[sender].usage == TokenUsage.Stake,
            "u r not stake nft"
        );
        uint256 reward = viewReward();

        require(reward > 0, " viewReward is zero");
        uint256 timestamp = block.timestamp;
        StakeInfo memory info = userStake[sender];

        uint256 time = timestamp >= info.endDate ? info.endDate : timestamp;

        userStake[sender].lastClaimDate =
            timestamp -
            ((time - userStake[sender].lastClaimDate) %
                userStake[sender].duration);

        userStake[sender].wasPaid += reward;

        stakingCoin.transfer(sender, reward);

        if (tokensRewardReserved > reward) {
            tokensRewardReserved -= reward;
        } else {
            tokensRewardReserved = 0;
        }
    }

    function viewReward() public view returns (uint256) {
        return _viewReward(_msgSender());
    }

    function _viewReward(address _addr) private view returns (uint256) {
        StakeInfo memory info = userStake[_addr];
        if (
            info.isStaking == true &&
            info.lastClaimDate < info.endDate &&
            info.lastClaimDate + info.duration < block.timestamp
        ) {
            uint256 timestamp = block.timestamp;

            uint256 time = timestamp >= info.endDate ? info.endDate : timestamp;
            uint256 count = (time - info.lastClaimDate) / info.duration;
            uint256 valRet = count * info.rewardPerDuration;
            return valRet;
        }
        return 0;
    }

    function play() external nonReentrant {
        address user = _msgSender();
        require(
            _addressUserMeta[user].usage == TokenUsage.No &&
                _addressUserMeta[user].dateExpirer > block.timestamp,
            "sorry, you cant p2y now"
        );
        _addressUserMeta[user].usage = TokenUsage.P2Y;
    }

    function canStake() public view returns (bool) {
        return
            stakeEnabled &&
            _addressUserMeta[msg.sender].dateExpirer > block.timestamp &&
            _addressUserMeta[msg.sender].usage == TokenUsage.No &&
            calcs() > 0;
    }

    function setStakeEnabled(bool _enable) external onlyOwner {
        stakeEnabled = _enable;
    }

    function setDuration(uint256 _duration) external onlyOwner {
        require(_duration != 0, "reward duration is zero");
        duration = _duration;
    }

    function dropStakingTokens() external onlyOwner {
        require(calcs() > 0, "not found tokens for");
        stakingCoin.transfer(owner(), calcs());
    }

    function rewardBNB(
        string memory hash,
        address[] memory _addrs,
        uint256[] memory _reward,
        uint256 totalReward
    ) external nonReentrant manager {
        require(
            _addrs.length == _reward.length,
            "_addrs.length != _reward.length"
        );

        require(wasRewardPaidBNB[hash] == false, "Reward was paid BNB");

        require(
            totalReward <= address(this).balance,
            "totalReward <= address(this).balance"
        );

        wasRewardPaidBNB[hash] = true;

        for (uint256 i = 0; i < _addrs.length; i++) {
            address addr = _addrs[i];
            UserMeta memory meta = _addressUserMeta[addr];
            if (meta.dateExpirer > block.timestamp) {
                uint256 reward = _reward[i];
                payable(addr).transfer(reward);
            }
        }

        emit RewardBNB(_msgSender(), block.timestamp, hash, totalReward);
    }

    function rewardTokens(
        address[] memory _addrs,
        uint256[] memory _reward,
        uint256 totalReward
    ) external nonReentrant manager {
        require(
            _addrs.length == _reward.length,
            "_addrs.length != _reward.length"
        );
        require(totalReward <= calcs(), "totalReward > address(this).balance");
        for (uint256 i = 0; i < _addrs.length; i++) {
            uint256 reward = _reward[i];
            stakingCoin.transfer(_addrs[i], reward);
        }
        emit RewardTokens(_msgSender(), block.timestamp, totalReward);
    }

    function setManager(address _addr, bool _enable) external onlyOwner {
        require(_addr != address(0), "address is zero");
        managers[_addr] = _enable;
    }
}