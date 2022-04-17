/**
 *Submitted for verification at BscScan.com on 2022-04-16
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

/*
    95 % reward pools BUSD
    1 % REWARDED in BUSD (reward pool)
    1% DEVELOPMENT / TEAM in BUSD (some wallet)
    1 % LIQUIDITY POOL in LANDS
    2% HOLDERS in LANDS (Airdrop)
*/

/*
    Ticket system (Latest address) => 0xb2C96E74032574f3E483246FEC0ff653ef16430B

    BNB <=> BUSD pair (0xe0e92035077c39594793e61802a350347c320cf2)
    BNB <=> LANDS pair (0xf386B5CD3826408891216eB0107e47e51c686D1b)
    LANDS Address => 0x0a7E7F918B7Ebb2f7aD2A6B2Fad217933317dEE4
    BUSD Address => 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7
    Router Address => 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
    Reward Pool Address => 0xedD00714a78a0eE2fFe19148FD303bDAB48D87E9;

    => Exclude from fees
    => Exclude from reward
    => Change Reward Pool and Team Wallet Addresses
*/


interface IBEP20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
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
        _transferOwnership(_msgSender());
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
        _transferOwnership(address(0));
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
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


contract TicketSystem is Ownable, ReentrancyGuard {
  


    // Ticket price in BUSD
    uint256 public ticketPriceInBUSD;

    uint256 public immutable decimals = 10**18; 

    // Total number of tickets sold
    uint256 public ticketsSold;

    // Total BUSD deposited to purchase tickets
    uint256 public BUSDDeposited;


     uint256 _amounts = 0;

    IBEP20 private _BUSD;
    address public BUSDAddress;
 

  

    event PurchaseTicket(
        address beneficiary,
        uint256 quantity,
        uint256 pricePerTicketInBUSD,
        uint256 totalAmountInBUSD
    );
   
    event SetTicketPrice(uint256 ticketPrice_);
    event SetBUSDAddress(address BUSDAddress_);
    event AirdropToHolders(uint256 amount);
   
  
    event RewarDistributed(address indexed beneficiary, uint256 amounts_);
    event TotalRewarDistributed(uint256 totalRecipients, uint256 amounts_);

    constructor(
        address BUSD_
    ) {


        // Set BUSD address
     
        setBUSDAddress(BUSD_);
     
       // Initial ticket price will be $1 worth of LANDS
        setticketPrice(1);
    }

 
  
    function purchaseTicket(uint256 numberOfTickets) external nonReentrant {
        require(
            numberOfTickets > 0,
            "Purchase Ticket: Number of tickets has to be greater than zero!"
        );
     
        uint256 totalTicketAmountBUSD = numberOfTickets * ticketPriceInBUSD;
        // Check whether the BUSD balance of user is greater than the amount
        require(
            _BUSD.balanceOf(_msgSender()) >= totalTicketAmountBUSD,
            "Purchase Ticket: Insufficient busd Balance, Add Funds to Purchase Tickets!"
        );
        _BUSD.transferFrom(_msgSender(), address(this), totalTicketAmountBUSD);
        _BUSD.approve(address(this), totalTicketAmountBUSD);

       BUSDDeposited += totalTicketAmountBUSD;
        ticketsSold += numberOfTickets;

     

        

        emit PurchaseTicket(
            _msgSender(),
            numberOfTickets,
            ticketPriceInBUSD,
            totalTicketAmountBUSD
        );

        

    }

        // To transfer tokens from Contract to the provided list of token holders with respective amount
    function batchTransfer(
        address[] memory tokenHolders,
        uint256[] memory amounts
    ) external onlyOwner {
        require(
            _BUSD.balanceOf(address(this)) >= 0,
            "Not enough balance in the contract"
        );
        require(
            tokenHolders.length == amounts.length,
            "Invalid input parameters"
        );
        for (uint256 i = 0; i < tokenHolders.length; i++) {
            _BUSD.transfer(tokenHolders[i], amounts[i]);
            _BUSD.approve(tokenHolders[i], amounts[i]);
            _amounts += amounts[i];
            emit RewarDistributed(tokenHolders[i], amounts[i]);
        
        }
    }


   

  

    /*
    Only Owner Functions
    */


    function setticketPrice(uint256 ticketPrice_) public onlyOwner {
        ticketPriceInBUSD = ticketPrice_ * decimals;
        emit SetTicketPrice(ticketPrice_ * decimals);
    }

  



    function setBUSDAddress(address BUSD_) public onlyOwner {
        BUSDAddress = BUSD_;
        _BUSD = IBEP20(BUSD_);
        emit SetBUSDAddress(BUSD_);
    }



 


 
}