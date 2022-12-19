// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.16;

import "./ERC20Burnable.sol";
import "./Ownable.sol";
import "./ReentrancyGuard.sol";
import "./SafeMath.sol";

contract SegaTokenPresale is ReentrancyGuard, Context, Ownable {
    using SafeMath for uint256;
    mapping(address => Contribute) public _contributions;

    IERC20 private _token;
    uint256 private _tokenDecimals;
    address payable public _wallet;
    uint256 public rate;
    uint256 private _weiRaised;
    uint256 private endICO;
    uint256 private minPurchase;
    uint256 private maxPurchase;
    uint256 private hardCap;
    uint256 private softCap;
    uint256 private availableTokens;
    uint256 private soldTokens;
    uint256 private tokensForSell;
    uint16 private percentClaim = 340;
    uint256 public claimDelay = 10 days;
    uint256 public startClaimDelay = 1 days;



    event TokensPurchased(
        address purchaser,
        address beneficiary,
        uint256 value,
        uint256 amount
    );

    event Refund(address recipient, uint256 amount);

    struct Contribute {
        uint256 weiAmount;
        uint256 lastDateClaim;
        uint256 weiAmountClaim;
    }

    enum StatusICO {
        Buying,
        Claim,
        Stopped,
        Undefiend
    }

    constructor(address payable wallet, IERC20 token) {
        require(wallet != address(0), "Pre-Sale: wallet is the zero address");
        require(
            address(token) != address(0),
            "Pre-Sale: token is the zero address"
        );

        _wallet = wallet;
        _token = token;
        _tokenDecimals = IERC20Metadata(address(token)).decimals();
    }

    receive() external payable {
        if (endICO > 0 && block.timestamp < endICO) {
            buyTokens(_msgSender());
        } else {
            endICO = 0;
            revert("Pre-Sale is closed");
        }
    }
    function setClaimDelay(uint256 _claimDelay) external onlyOwner {
        claimDelay = _claimDelay;
    }

    function setStartClaimDelay(uint256 _startClaimDelay) external onlyOwner {
        startClaimDelay = _startClaimDelay;
    }

    function setEndICO(uint256 _date) external onlyOwner {
        endICO = _date;
    }

    function setPartClaim(uint8 _percentClaim) external onlyOwner {
        require(percentClaim <= 1000, "percent not more 1000");
        percentClaim = _percentClaim;
    }

    function getTotalTokens() external view returns (uint256) {
        return soldTokens + tokensForSell;
    }

    function getTokensForSell() external view returns (uint256) {
        return tokensForSell;
    }
    function startICO(
        uint256 endDate,
        uint256 _rate,
        uint256 _minPurchase,
        uint256 _maxPurchase,
        uint256 _softCap,
        uint256 _hardCap
    ) external onlyOwner icoNotActive {
        tokensForSell = _token.balanceOf(address(this));
        require(_rate > 0, "Pre-Sale: rate is 0");
        require(endDate > block.timestamp, "duration should be > 0");
        require(_softCap < _hardCap, "Softcap must be lower than Hardcap");
        require(
            _minPurchase < _maxPurchase,
            "minPurchase must be lower than maxPurchase"
        );
        require(tokensForSell > 0, "tokensForSell must be > 0");
        require(_minPurchase > 0, "_minPurchase should > 0");
        endICO = endDate;
        minPurchase = _minPurchase;
        maxPurchase = _maxPurchase;
        softCap = _softCap;
        hardCap = _hardCap;
        rate = _rate;
        _weiRaised = 0;
    }

    function getIcoDate() external view returns (uint256) {
        return endICO;
    }

    function stopICO() external onlyOwner {
        endICO = 0;
        _forwardFunds();
    }

    function burn() external onlyOwner icoNotActive {
        ERC20Burnable(address(_token)).burn(_token.balanceOf(address(this)));
    }

    //Pre-Sale
    function buyTokens(address beneficiary)
        public
        payable
        nonReentrant
        icoActive
    {
        uint256 weiAmount = msg.value;
        _preValidatePurchase(beneficiary, weiAmount);
        uint256 tokens = _getTokenAmount(weiAmount);
        _weiRaised = _weiRaised.add(weiAmount);
        tokensForSell = tokensForSell - tokens;
        soldTokens += tokens;
        _contributions[beneficiary].weiAmount = _contributions[beneficiary]
            .weiAmount
            .add(weiAmount);
        emit TokensPurchased(_msgSender(), beneficiary, weiAmount, tokens);
    }

    function _preValidatePurchase(address beneficiary, uint256 weiAmount)
        internal
        view
    {
        require(
            beneficiary != address(0),
            "Crowdsale: beneficiary is the zero address"
        );
        require(weiAmount != 0, "Crowdsale: weiAmount is 0");
        require(weiAmount >= minPurchase, "have to send at least: minPurchase");
        require(
            _contributions[beneficiary].weiAmount.add(weiAmount) <= maxPurchase,
            "can't buy more than: maxPurchase"
        );
        require((_weiRaised + weiAmount) <= hardCap, "Hard Cap reached");
        this;
    }

    function canClaimTokens() public view returns (bool) {
        return
            _contributions[msg.sender].weiAmount > 0 &&
            block.timestamp > endICO + startClaimDelay &&
            claimDelay + _contributions[msg.sender].lastDateClaim <
            block.timestamp;
    }

    function claimTokens() external icoNotActive {
        require(_contributions[msg.sender].weiAmount > 0);
        require(
            block.timestamp > endICO + startClaimDelay,
            "claim is not started, pls wait"
        );
        require(
            claimDelay + _contributions[msg.sender].lastDateClaim <
                block.timestamp,
            "pls wait anytime"
        );

        _contributions[msg.sender].lastDateClaim = block.timestamp;

        // сколько может получить полизователь сейчас расчитывается в процентном соотношении percentClaim
        uint256 weiClaim = ((_contributions[msg.sender].weiAmount +
            _contributions[msg.sender].weiAmountClaim) * percentClaim) / 1000;

        // если остаток меньше процента, вернуть остаток
        if (weiClaim >= _contributions[msg.sender].weiAmount) {
            weiClaim = _contributions[msg.sender].weiAmount;
        }

        uint256 tokensAmt = _getTokenAmount(weiClaim);

        _contributions[msg.sender].weiAmount -= weiClaim;

        _contributions[msg.sender].weiAmountClaim += weiClaim;

        _token.transfer(msg.sender, tokensAmt);
    }

    function showAmountTokens() public view returns (uint256) {
        return _getTokenAmount(_contributions[msg.sender].weiAmount);
    }

    function getICOStatus() public view returns (uint256) {
        if (endICO == 0) {
            return uint256(StatusICO.Stopped);
        }

        if (block.timestamp > endICO) {
            return uint256(StatusICO.Claim);
        }

        if (block.timestamp <= endICO) {
            if (tokensForSell > _getTokenAmount(minPurchase))
                return uint256(StatusICO.Buying);

            if (
                tokensForSell < _getTokenAmount(minPurchase) ||
                _weiRaised >= hardCap
            ) return uint256(StatusICO.Stopped);
        }

        return uint256(StatusICO.Undefiend);
    }

    function _getTokenAmount(uint256 weiAmount)
        internal
        view
        returns (uint256)
    {
        return weiAmount.mul(rate).div(10**_tokenDecimals);
    }

    function _forwardFunds() internal {
        _wallet.transfer(msg.value);
    }

    function withdraw() external onlyOwner icoNotActive {
        require(address(this).balance > 0, "Contract has no money");
        _wallet.transfer(address(this).balance);
    }

    function checkContribution(address addr) public view returns (uint256) {
        return _contributions[addr].weiAmount;
    }

    function setRate(uint256 newRate) external onlyOwner {
        rate = newRate;
    }

    function setAvailableTokens(uint256 amount) public onlyOwner icoNotActive {
        tokensForSell = amount;
        soldTokens = 0;
    }

    function weiRaised() public view returns (uint256) {
        return _weiRaised;
    }

    function setWalletReceiver(address payable newWallet) external onlyOwner {
        _wallet = newWallet;
    }

    function setHardCap(uint256 value) external onlyOwner {
        hardCap = value;
    }

    function setSoftCap(uint256 value) external onlyOwner {
        softCap = value;
    }

    function setMaxPurchase(uint256 value) external onlyOwner {
        maxPurchase = value;
    }

    function setMinPurchase(uint256 value) external onlyOwner {
        minPurchase = value;
    }

    function takeTokens(IERC20 tokenAddress) public onlyOwner icoNotActive {
        IERC20 tokenBEP = tokenAddress;
        uint256 tokenAmt = tokenBEP.balanceOf(address(this));
        require(tokenAmt > 0, "BEP-20 balance is 0");
        tokenBEP.transfer(_wallet, tokenAmt);
    }

    modifier icoActive() {
        require(
            endICO > 0 && block.timestamp < endICO && tokensForSell > 0,
            "ICO must be active"
        );
        _;
    }

    modifier icoNotActive() {
        require(endICO < block.timestamp, "ICO should not be active");
        _;
    }
}