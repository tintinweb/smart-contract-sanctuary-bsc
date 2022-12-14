/**
 *Submitted for verification at BscScan.com on 2022-12-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface BEP20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract InvestmentContract {
    struct User {
        uint256 investment;
        uint256 deposit;
        uint256 profit;
        uint256 rate;
        uint256 reinvestCheckPoint;
        uint256 withdrawCheckPoint;
        uint256 reinvests;
        uint256 withdrawal;
        uint256 refIncome;
        uint256[4] refs;
        address referrer;
        bool rateSet;
    }
    mapping(address => uint256) public investments;
    mapping(address => User) public users;
}

contract BMPTokenPreSale is Ownable {
    // address of admin
    BEP20 public token;
    // token price variable
    uint256 public tokenprice;
    // count of token sold vaariable
    uint256 public totalsold;

    address public ceoWallet;
    address public devWallet;
    address public adminWallet;
    address public insuranceWallet;
    address public marketingWallet;
    address public tradingWallet;
    address public liquidityWallet;

    // contract addresses for whitlisting
    address public FastAndFurious;
    address public BNBMinerPirates;
    address public BMPWorldCup_V2;
    address public WADJET;
    address public ThePaperHouse;

    bool public saleEnded = true;
    bool public isPrivateSale = false;

    mapping(address => bool) whitelist;
    mapping(uint256 => mapping(address => uint256)) purchases;
    uint256 public saleId;
    uint256 public saleLimit;

    event Sell(address sender, uint256 totalvalue, address referral);

    // constructor
    constructor(
        address _ceoWallet,
        address _devWallet,
        address _adminWallet,
        address _insuranceWallet,
        address _marketingWallet,
        address _tradingWallet,
        address _liquidityWallet
    ) {
        ceoWallet = _ceoWallet;
        devWallet = _devWallet;
        adminWallet = _adminWallet;
        insuranceWallet = _insuranceWallet;
        marketingWallet = _marketingWallet;
        tradingWallet = _tradingWallet;
        liquidityWallet = _liquidityWallet;
    }

    // private sale function
    function buyTokensPrivate() public payable {
        require(isPrivateSale, "Not private");
        //TODO: check if this is a customer or not
        require(
            InvestmentContract(FastAndFurious).investments(msg.sender) > 0 ||
                InvestmentContract(BNBMinerPirates).investments(msg.sender) >
                0 ||
                InvestmentContract(ThePaperHouse).investments(msg.sender) > 0 ||
                InvestmentContract(BMPWorldCup_V2).investments(msg.sender) >
                0 ||
                checkInvestedWadjet(msg.sender) ||
                whitelist[msg.sender] == true,
            "not allowed"
        );
        buyTokens(address(0));
    }

    function checkInvestedWadjet(address _address) public view returns (bool) {
        (uint256 investment, , , , , , , , , , ) = InvestmentContract(WADJET)
            .users(_address);
        return investment > 0;
    }

    // public sale
    function buyTokensPublic(address referral) public payable {
        require(!isPrivateSale, "Not public");
        buyTokens(referral);
    }

    // buyTokens function
    function buyTokens(address referral) private {
        require(!saleEnded, "Sale ended");

        address buyer = msg.sender;
        uint256 bnbAmount = msg.value;
        uint256 tokenAmount = bnbAmount * tokenprice;
        require(
            purchases[saleId][msg.sender] + tokenAmount <= saleLimit,
            "max sale limit is exceeded"
        );
        // check if the contract has the tokens or not
        require(
            token.balanceOf(address(this)) >= tokenAmount,
            "the smart contract dont hold the enough tokens"
        );
        // transfer the token to the user
        token.transfer(buyer, tokenAmount);
        // increase the token sold
        totalsold += tokenAmount;
        purchases[saleId][msg.sender] += tokenAmount;
        // pay referral
        if (referral != address(0)) {
            token.transfer(referral, (tokenAmount * 5) / 100);
        }
        // pay community and owners
        payCommunity();
        // emit sell event for ui
        emit Sell(buyer, tokenAmount, referral);
    }

    // create sale
    function createSale(
        uint256 _tokenvalue,
        bool _isPrivate,
        uint256 _limit
    ) public onlyOwner {
        require(saleEnded, "Another open slae");
        tokenprice = _tokenvalue;
        saleEnded = false;
        isPrivateSale = _isPrivate;
        saleLimit = _limit;
        saleId = saleId + 1;
    }

    // end sale
    function endSale() public onlyOwner {
        require(!saleEnded, "Sale already ended");
        // transfer all the remaining tokens to admin
        token.transfer(msg.sender, token.balanceOf(address(this)));
        // transfer all the remaining funds to admin
        saleEnded = true;
        payable(msg.sender).transfer(address(this).balance);
    }

    function payCommunity() private {
        uint balance = address(this).balance;
        payable(ceoWallet).transfer((balance * 2) / 100);
        payable(devWallet).transfer((balance * 2) / 100);
        payable(adminWallet).transfer((balance * 2) / 100);
        payable(insuranceWallet).transfer((balance * 2) / 100);
        payable(marketingWallet).transfer((balance * 2) / 100);
        payable(tradingWallet).transfer((balance * 40) / 100);
        payable(liquidityWallet).transfer(address(this).balance);
    }

    // change contract addresses for whitlisting
    function setFastAndFurious(address _address) external onlyOwner {
        FastAndFurious = _address;
    }

    function setBNBMinerPirates(address _address) external onlyOwner {
        BNBMinerPirates = _address;
    }

    function setBMPWorldCup_V2(address _address) external onlyOwner {
        BMPWorldCup_V2 = _address;
    }

    function setWADJET(address _address) external onlyOwner {
        WADJET = _address;
    }

    function setThePaperHouse(address _address) external onlyOwner {
        ThePaperHouse = _address;
    }

    function setToken(address _address) external onlyOwner {
        token = BEP20(_address);
    }

    function setWhitelist(address _address, bool _value) external onlyOwner {
        whitelist[_address] = _value;
    }
}