pragma solidity ^0.5.16;

import "./Ownable.sol";
import "./FCards.sol";
import "./Strings.sol";
import "./SafeMath.sol";
import "./IERC20.sol";
import "./Address.sol";
import "./erc1155MockR.sol";
import "./IUniswapV2Router02.sol";

contract fmanStakingV3 is Ownable, ERC1155MockReceiver {
    using SafeMath for uint256;
    using Strings for string;

    uint256 public rewardWholeSeason = 200;
    uint256 public reward4s = 100;
    uint256 public reward5s = 180;
    uint256 public interval = 200;
    uint256 public p3 = 10;
    uint256 public p4 = 40;
    uint256 public p5 = 50;
    uint256 public fmanMaxWallet = 2000000000000000000000000000000;
    uint256 private rewardFor3 = 0;
    uint256 private rewardFor4 = 0;
    uint256 private rewardFor5 = 0;

    string public name = "FMAN Staking V3";
    string public symbol = "FMANSTAKE";

    mapping(address => mapping(uint256 => uint256)) internal cardBalance;
    mapping(address => mapping(uint256 => uint256)) internal rankBalance;

    uint256[] internal cardList = [1,2,3,4,5,6,7];
    uint256[] internal seasonList = [1];

    address[] private otAddresses;
    mapping(address => bool) private otSeenAddy;

    mapping(uint256 => uint256) public totalLockedPerRank;

    uint256 private tvl = 0;

    bool public stakeIsLocked = false;
    bool public useDollars = true;

    // FMAN Token Contract Addy
    address public fmanAddy = 0xC2aEbbBc596261D0bE3b41812820dad54508575b;
    address private busdAddy = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public nftAddy = 0x403336AE5440FE5e0c1A1aD977273B20013CF79B;
    fmanCards fmanft;
    IERC20 fman;
    IUniswapV2Router02 pcsRouter;

    // Address of owner wallet
    address payable private ownerAddress;

    // Address of NFT dev
    address payable private devAddress;

    struct seasonData {
        uint256 otpReward;
        uint256[] cIds;
    }

    mapping(uint256 => seasonData) public seasonById;

    // Modifiers
    modifier onlyDev() {
        require(
            devAddress == msg.sender,
            "dev: only dev can change their address."
        );
        _;
    }

    modifier unlockedStake() {
        require(
            !stakeIsLocked,
            "Deposits and withdrawals are paused at the moment. Please hold on.."
        );
        _;
    }

    constructor(
        address payable _devAddress
    ) public {
        ownerAddress = msg.sender;
        devAddress = _devAddress;
        pcsRouter = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        fmanft = fmanCards(nftAddy);
        fman = IERC20(fmanAddy);
    }

    function setSeasonData(uint256 otpReward, uint256 seasonId, uint256[] memory cardIds) public onlyOwner{
        require(fmanft.validSeason(seasonId),"Season ID is not valid");

        for (uint256 i = 0; i < cardIds.length; i++) {
            require(fmanft.validCard(cardIds[i]),"Card ID is not valid");
        }

        seasonById[seasonId] = seasonData(otpReward, cardIds);
    }

    function setCardList(uint256[] memory cardIds) public onlyOwner {
        require(cardIds.length>0,"Card list is empty");
        cardList = cardIds;
    }

    function setSeasonList(uint256[] memory seasonIds) public onlyOwner {
        require(seasonIds.length>0,"Season list is empty");
        seasonList = seasonIds;
    }

    function setBusdAddress(address addy) public onlyOwner {
        busdAddy = addy;
    }

    function setRouterAddress(address addy) public onlyOwner {
        pcsRouter = IUniswapV2Router02(addy);
    }

    function setOTPRewards(uint256 seasonId, uint256 reward) public onlyOwner{
        seasonData storage season = seasonById[seasonId];
        season.otpReward = reward;
    }

    function setUseDollars(bool use) public onlyOwner {
        useDollars = use;
    }

    function depositeAll() public {
        for (uint256 i = 0; i < cardList.length; i++) {
            if(fmanft.balanceOf(msg.sender, cardList[i])>0){
                deposite(cardList[i],fmanft.balanceOf(msg.sender, cardList[i]), "");
            }
        }
    }

    function batchDeposite(uint256[] memory cardIds, uint256[] memory quantities) public {
        require(cardIds.length>0, "Empty List");
        require(cardIds.length==quantities.length, "Card and quantity lists need to be same size");
        for (uint256 i = 0; i < cardIds.length; i++) {
            deposite(cardIds[i],quantities[i],"");
        }
    }

    function batchWithdraw(uint256[] memory cardIds, uint256[] memory quantities) public {
        require(cardIds.length>0, "Empty List");
        require(cardIds.length==quantities.length, "Card and quantity lists need to be same size");
        for (uint256 i = 0; i < cardIds.length; i++) {
            withdraw(cardIds[i],quantities[i],"");
        }
    }


    function setFmanMaxWallet(uint256 maxWallet) external onlyOwner{
        fmanMaxWallet = maxWallet * 10**18;
    }

    function setIterationInterval(uint256 i) external onlyOwner {
        interval = i;
    }

    function setOwnerAddress(address payable addy) external onlyOwner{
        ownerAddress = addy;
        transferOwnership(addy);
    }

    function numberOfAddresses() external view returns(uint256){
        return otAddresses.length;
    }

    function balanceOf(address user, uint256 id) external view returns(uint256){
        require(fmanft.validCard(id), "invalid card id");
        return cardBalance[user][id];
    }

    function setRewardSplits(
        uint256 _ratio3,
        uint256 _ratio4,
        uint256 _ratio5
    ) external onlyOwner {
        require(
            _ratio3 + _ratio4 + _ratio5 == 100,
            "should add up to 100"
        );
        p3 = _ratio3;
        p4 = _ratio4;
        p5 = _ratio5;
    }

    function withdrawToken(address tokenAddy) public onlyOwner {
        uint256 balance = IERC20(tokenAddy).balanceOf(address(this));
        // 5% goes to NFT dev
        uint256 balanceForDev = balance.div(10).div(2);
        uint256 deltaBalance = balance.sub(balanceForDev);
        IERC20(tokenAddy).transfer(devAddress, balanceForDev);
        IERC20(tokenAddy).transfer(ownerAddress, deltaBalance);
    }

    function approveNfts(address operator) public onlyOwner {
        fmanft.setApprovalForAll(operator,true);
    }

    function WithdrawBeans() public onlyOwner {
        uint256 balance = address(this).balance;
        // 5% goes to NFT dev
        uint256 balanceForDev = balance.div(10).div(2);
        uint256 deltaBalance = balance.sub(balanceForDev);
        devAddress.transfer(balanceForDev);
        ownerAddress.transfer(deltaBalance);
    }

    function deposite(
        uint256 id,
        uint256 qnt,
        bytes memory _data
    ) public unlockedStake {
        require(fmanft.validCard(id), "Invalid card Id");
        require(qnt > 0, "Please increase quantity from 0");
        require(
            fmanft.balanceOf(msg.sender, id) >= qnt,
            "Make sure you have the quantity u want to deposite."
        );
        (, , , , uint256 rank) = fmanft.cardById(id);
        totalLockedPerRank[rank] += qnt;
        if (!otSeenAddy[msg.sender]) {
            otSeenAddy[msg.sender] = true;
            otAddresses.push(msg.sender);
        }
        cardBalance[msg.sender][id] += qnt;
        rankBalance[msg.sender][rank] += qnt;
        tvl += qnt;

        fmanft.safeTransferFrom(msg.sender, address(this), id, qnt, _data);
    }

    function withdraw(
        uint256 id,
        uint256 qnt,
        bytes memory _data
    ) public unlockedStake {
        require(fmanft.validCard(id), "Invalid card Id");
        require(qnt > 0, "Please increase quantity from 0");
        require(
            cardBalance[msg.sender][id] >= qnt,
            "Make sure you have the quantity u want to withdraw."
        );
        (, , , , uint256 rank) = fmanft.cardById(id);
        totalLockedPerRank[rank] -= qnt;
        rankBalance[msg.sender][rank] -= qnt;
        cardBalance[msg.sender][id] -= qnt;
        tvl -= qnt;

        fmanft.safeTransferFrom(address(this), msg.sender, id, qnt, _data);
    }

    function numSets(address user, uint256 seasonId) internal view returns (uint256) {
        require(fmanft.validSeason(seasonId), "invalid season Id");
        seasonData memory season = seasonById[seasonId];
        uint256 min = 2**256 - 1;
        for (uint256 i = 0; i < season.cIds.length; i++) {
            if(cardBalance[user][season.cIds[i]]<min){
                min = cardBalance[user][season.cIds[i]];
            }
        }
        return min;
    }

    function hasSet(address user, uint256 seasonId) internal view returns (bool) {
        require(fmanft.validSeason(seasonId), "invalid season Id");
        seasonData memory season = seasonById[seasonId];
        for (uint256 i = 0; i < season.cIds.length; i++) {
            if(cardBalance[user][season.cIds[i]]<1){
                return false;
            }
        }
        return true;
    }

    function otDistro(uint256 index) public onlyOwner {
        require(stakeIsLocked, "Please initialize distro first");
        require(index < otAddresses.length, "index larger than array size");
        uint256 range = min(index + interval, otAddresses.length);
        for (uint256 i = index; i < range; i++) {
            uint256 payableAmt = 0;
            for (uint256 j = 0; j < seasonList.length; j++) {
                seasonData memory season = seasonById[seasonList[j]];
                uint256 setCount = numSets(otAddresses[i], seasonList[j]);
                if (useDollars && setCount>0){
                    payableAmt += fmanFromDollar(season.otpReward.mul(setCount));
                }
                else {
                    payableAmt += season.otpReward.mul(setCount);
                }
            }
            if (
                payableAmt > 0 &&
                fman.balanceOf(otAddresses[i]) + payableAmt < fmanMaxWallet
            ) {
                fman.transfer(otAddresses[i], payableAmt);
            }
        }
    }

    function fmanFromDollar(uint256 amount) public view returns (uint256 fmanAmount){
        address[] memory path = new address[](2);
        path[0] = busdAddy;
        path[1] = fmanAddy;
        return pcsRouter.getAmountsOut(amount,path)[1] * 10**18;
    }

    function calculateOTP(uint256 seasonId, bool _useDollars) public view returns (uint256 amount) {
        uint256 payableAmt = 0;
        seasonData memory season = seasonById[seasonId];
        uint256 rewardFman = season.otpReward;
        if(_useDollars){
            rewardFman = fmanFromDollar(season.otpReward);
        }
        for (uint256 i = 0; i < otAddresses.length; i++) {
            uint256 setCount = numSets(otAddresses[i], seasonId);
            payableAmt += rewardFman.mul(setCount);
        }
        return payableAmt;
    }

    function calculateTotalOTP(bool _useDollars) public view returns (uint256 amount) {
        uint256 payableAmt = 0;
        for(uint256 i = 0; i < seasonList.length; i++){
            payableAmt += calculateOTP(seasonList[i], _useDollars);
        }
        return payableAmt;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256) {
        if (x < y) {
            return x;
        } else {
            return y;
        }
    }

    function totalSupply() external view returns(uint256){
        return tvl;
    }

    function initializeDistro(bool includeOneTimePayment) external onlyOwner {
        stakeIsLocked = true;
        resetRewards();
        uint256 bal = fman.balanceOf(address(this));
        uint256 balToOt = 0;
        if (includeOneTimePayment) {
            balToOt = calculateTotalOTP(useDollars);
        }
        uint256 balToDistro = bal.sub(balToOt);
        uint256 amt3 = balToDistro.mul(p3).div(100);
        uint256 amt4 = balToDistro.mul(p4).div(100);
        uint256 amt5 = balToDistro.sub(amt3).sub(amt4);
        if (totalLockedPerRank[3] > 0) {
            rewardFor3 = amt3.div(totalLockedPerRank[3]);
        }
        if (totalLockedPerRank[4] > 0) {
            rewardFor4 = amt4.div(totalLockedPerRank[4]);
        }
        if (totalLockedPerRank[5] > 0) {
            rewardFor5 = amt5.div(totalLockedPerRank[5]);
        }
    }

    function resetRewards() internal {
        rewardFor3 = 0;
        rewardFor4 = 0;
        rewardFor5 = 0;
    }

    function finalizeDistro() external onlyOwner {
        stakeIsLocked = false;
        resetRewards();
    }

    function distro(uint256 index) public onlyOwner {
        require(stakeIsLocked, "Please initialize distro first");
        require(index < otAddresses.length, "index larger than array size");
        uint256 range = min(index + interval, otAddresses.length);
        for (uint256 i = index; i < range; i++) {
            uint256 payableAmt = 0;
            payableAmt += rewardFor3.mul(rankBalance[otAddresses[i]][3]);
            payableAmt += rewardFor4.mul(rankBalance[otAddresses[i]][4]);
            payableAmt += rewardFor5.mul(rankBalance[otAddresses[i]][5]);
            if (
                payableAmt > 0 &&
                fman.balanceOf(otAddresses[i]) + payableAmt < fmanMaxWallet
            ) {
                fman.transfer(otAddresses[i], payableAmt);
            }
        }
    }
}