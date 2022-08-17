/**
 *Submitted for verification at BscScan.com on 2022-08-16
*/

// SPDX-License-Identifier: MIT

// File: contracts/interfaces/IBEP20.sol




pragma solidity ^0.8.0;


interface IBEP20 {

    event Transfer(address indexed from, address indexed to, uint256 value);


    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: contracts/Context.sol



pragma solidity ^0.8.0;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: contracts/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;



abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }


    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }




    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }


    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: contracts/TokenSale.sol


pragma solidity ^0.8.9;



contract Whitelist {
    mapping(address => bool) public whitelist;

    function _addToWhitelist(address _beneficiary) internal {
        whitelist[_beneficiary] = true;
    }

    function _addManyToWhitelist(address[] memory _beneficiaries) internal {
        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            whitelist[_beneficiaries[i]] = true;
        }
    }

    function _removeFromWhitelist(address _beneficiary) internal {
        whitelist[_beneficiary] = false;
    }

    function _removeManyFromWhitelist(address[] memory _beneficiaries)
        internal
    {
        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            whitelist[_beneficiaries[i]] = false;
        }
    }
}

contract Pausable {
    bool public paused;

    modifier whenNotPaused() {
        require(!paused, "sale is paused");
        _;
    }

    function _pauseSale() internal {
        require(!paused, "Sale already paused");
        paused = true;
    }

    function _unPauseSale() internal {
        require(paused, "Sale is not paused");
        paused = false;
    }
}

contract TokenSale is Whitelist, Ownable, Pausable {
    uint256 public presaleRate;
    uint256 public publicsaleRate;

    uint256 public presaleTimestamp;
    uint256 public publicsaleStartTimestamp;
    uint256 public publicsaleEndTimestamp;

    uint256 public unverifiedLimit;
    uint256 public verifiedLimit;

    uint256 public walletCut;
    uint256 public charityCut;

    address payable public wallet;
    address payable public charityWallet;
    address public whitelister;

    IBEP20 public token;

    mapping(address => uint256) public contributions;

    event TokenPurchase(
        address indexed purchaser,
        address indexed beneficiary,
        uint256 value,
        uint256 amount
    );

    constructor(
        uint256 _presaleRate,
        uint256 _publicsaleRate,
   
        uint256 _presaleTimestamp,
        uint256 _publicsaleStartTimestamp,
        uint256 _publicsaleEndTimestamp,
        uint256 _unverifiedLimit,
        uint256 _verifiedLimit,
        uint256 _walletCut,
        uint256 _charityCut,
        address payable _wallet,
        address payable _charityWallet,
        address _token
    ) {
        require(_publicsaleRate > 0);
        require(_presaleRate > 0);
        require(_wallet != address(0) && _charityWallet != address(0));
        require(address(_token) != address(0));
        
        presaleRate = _presaleRate;
        publicsaleRate = _publicsaleRate;

        unverifiedLimit = _unverifiedLimit;
        verifiedLimit = _verifiedLimit;

        presaleTimestamp = _presaleTimestamp;
        publicsaleStartTimestamp = _publicsaleStartTimestamp;
        publicsaleEndTimestamp = _publicsaleEndTimestamp;

        setCuts(_walletCut, _charityCut);

        whitelister = msg.sender;
        charityWallet = _charityWallet;
        wallet = _wallet;

        token = IBEP20(_token);
    }

    modifier onlyWhitelister() {
        require(msg.sender == whitelister, "only Whitelister");
        _;
    }

    function setWhiteListerAddress(address _whitelister) external onlyOwner {
        whitelister = _whitelister;
    }

    function pauseSale() external onlyOwner {
        _pauseSale();
    }

    function unPauseSale() external onlyOwner {
        _unPauseSale();
    }

    function setCuts(uint256 _walletCut, uint256 _charityCut) public onlyOwner {
        /*
        sets the Cuts for The fundsWallet and the charityWallet
            Percentages are calculated in Bips (Basis Points)
            Examples : 
                100 % = 10000 pibs
                15.5% = 1550 pibs
                2.57% = 257 pibs
        Note: Sum of the Cuts should be 10000 
        */
        require(_walletCut + _charityCut == 10000, "cuts should sum to 10000");
        walletCut = _walletCut;
        charityCut = _charityCut;
    }

    function buyTokens(address beneficiary)
        public
        payable
        whenNotPaused
        
    {
        uint256 weiAmount = msg.value;
        _preValidatePurchase(beneficiary, weiAmount);
        uint256 tokens = _getTokenAmount(weiAmount);
        _updatePurchasingState(beneficiary, weiAmount);
        _processPurchase(beneficiary, tokens);
        _forwardFunds();

        emit TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
    }

    function _preValidatePurchase(address beneficiary, uint256 _weiAmount)
        internal
        view
    {
        require(block.timestamp > presaleTimestamp, "sale hasn't started");
        require(block.timestamp < publicsaleEndTimestamp, "sale is over");
        require(beneficiary != address(0));
        require(_weiAmount != 0);

        uint256 total = contributions[beneficiary] + _weiAmount;
        require(total <= verifiedLimit, "Exceed max amount");

        if (total > unverifiedLimit) {
            require(whitelist[beneficiary], "Not verified");
        }

    }

    function _updatePurchasingState(address _beneficiary, uint256 _weiAmount)
        internal
    {
        contributions[_beneficiary] += _weiAmount;
    }

    function _getTokenAmount(uint256 _weiAmount)
        internal
        view
        returns (uint256)
    {
        return _weiAmount * getRate();
    }

    function getRate() public view returns (uint256) {
        if (block.timestamp < publicsaleStartTimestamp) {
            return presaleRate;
        }
        return publicsaleRate;
    }

    function _processPurchase(address _beneficiary, uint256 _tokenAmount)
        internal
    {
        bool success = token.transfer(_beneficiary, _tokenAmount);
        require(success, "Transfer Failed");
    }

    function _forwardFunds() internal {
        _splitFunds(msg.value);
    }

    function withdrowFunds() external onlyOwner {
        uint256 amount = address(this).balance;
        _splitFunds(amount);
    }

    function _splitFunds(uint256 _amount) internal {
        uint256 walletAmount = (_amount * walletCut) / 10000;
        uint256 charityAmount = (_amount * charityCut) / 10000;
        _safeTransfer(charityWallet, charityAmount);
        _safeTransfer(wallet, walletAmount);
    }

    function _safeTransfer(address _to, uint256 _value) internal {
        (bool success, ) = _to.call{value: _value}("");
        require(success, "Transfer Failed.");
    }

    function addToWhitelist(address _beneficiary) external onlyWhitelister {
        _addToWhitelist(_beneficiary);
    }

    function addManyToWhitelist(address[] memory _beneficiaries)
        external
        onlyWhitelister
    {
        _addManyToWhitelist(_beneficiaries);
    }

    function removeFromWhitelist(address _beneficiary)
        external
        onlyWhitelister
    {
        _removeFromWhitelist(_beneficiary);
    }

    function removeManyFromWhitelist(address[] memory _beneficiaries)
        external
        onlyWhitelister
    {
        _removeManyFromWhitelist(_beneficiaries);
    }

    function setPresaleTimeStamp(uint256 _newTimestamp) external onlyOwner {
        require(
            block.timestamp < _newTimestamp,
            "Timestamp should be in the future"
        );
        require(block.timestamp < presaleTimestamp, "presale already started");
        presaleTimestamp = _newTimestamp;
    }

    function setPublicsaleStartTimeStamp(uint256 _newTimestamp)
        external
        onlyOwner
    {
        require(
            block.timestamp < _newTimestamp,
            "Timestamp should be in the future"
        );
        require(
            block.timestamp < publicsaleStartTimestamp,
            "publicsale Already started"
        );

        require(
            _newTimestamp > presaleTimestamp,
            "Publicsale should be after presale"
        );

        require(
            _newTimestamp < publicsaleEndTimestamp,
            "Timestamp should before the publicsaleEndTimestamp"
        );
        publicsaleStartTimestamp = _newTimestamp;
    }

    function setPublicsaleEndTimeStamp(uint256 _newTimestamp)
        external
        onlyOwner
    {
        require(
            block.timestamp < _newTimestamp,
            "Timestamp should be in the future"
        );
        require(block.timestamp < publicsaleEndTimestamp, "sale finished");


        require(
            _newTimestamp > publicsaleStartTimestamp,
            "Publicsale should be after publicsaleStartTimestamp"
        );

        publicsaleStartTimestamp = _newTimestamp;
    }

    function setUnverifiedLimit(uint256 _newLimit) external onlyOwner {
        require(_newLimit != unverifiedLimit, "new limit equals old limit");
        require(_newLimit != 0, "new limit = 0");

        unverifiedLimit = _newLimit;
    }

    function setVerifiedLimit(uint256 _newLimit) external onlyOwner {
        require(_newLimit != verifiedLimit, "new limit equals old limit");
        require(_newLimit != 0, "new limit = 0");

        verifiedLimit = _newLimit;
    }

    function setWallet(address payable _newWallet) external onlyOwner {
        require(_newWallet != address(0), "address 0");
        wallet = _newWallet;
    }

    function setCharityWallet(address payable _newWallet) external onlyOwner {
        require(_newWallet != address(0), "address 0");
        charityWallet = _newWallet;
    }

    function claimRemainingTokens() external onlyOwner {
        require(
            block.timestamp > publicsaleEndTimestamp,
            "sale is not finished"
        );
        bool success = token.transfer(
            msg.sender,
            token.balanceOf(address(this))
        );
        require(success, "Transfer Failed");
    }

    function recoverBEP20(address tokenAddress, uint256 tokenAmount)
        public
        onlyOwner
    {
        require(tokenAddress != address(token));
        IBEP20(tokenAddress).transfer(msg.sender, tokenAmount);
    }

    fallback() external payable {
        buyTokens(msg.sender);
    }

    receive() external payable {
        buyTokens(msg.sender);
    }
}