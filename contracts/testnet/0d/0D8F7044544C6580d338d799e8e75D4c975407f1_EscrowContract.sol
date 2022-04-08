/**
 *Submitted for verification at BscScan.com on 2022-04-08
*/

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

interface IPancakeV2Router {
    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);
}

interface ICustomerContract {
    function deposit() external returns (uint256 tokens);
    function verify(uint256 key) external;
}

interface IMindsyncPlatform {
    function deposit(uint256 amount) external;
}

interface IEscrowContract {
    function escrowContract() external returns (address);
    function platformContract() external returns (address);
    function WBNB() external returns (address);
    function PANCAKESWAP_V2_ROUTER() external returns (address);
    function mediaContract() external returns (address);
    function emitDepositEvent(address sender, uint256 amount) external;
}

contract CustomerContract {
    // Mindsync Escrow contract (basic escrow contract address)
    address public escrowContract = address(0);

    constructor(address escrow) {                 
        escrowContract = escrow;       
    } 

    /**
     * @dev receive function that is executed on BNB transfers.
     */     
    receive() external payable {
        if (gasleft() >= 250000) {
            // Perform a full deposit cycle
            deposit();
        }
        else {
            // Emit a deposit event on escrow contract to complete a deposit using backend
            address escrowContract_ = IEscrowContract(escrowContract).escrowContract();
            escrowContract_ = (escrowContract_ != address(0)) ? escrowContract_ : escrowContract;
            IEscrowContract(escrowContract_).emitDepositEvent(address(msg.sender), address(this).balance);
        }
    }

    /**
     * @dev receive function that is executed on BNB transfers.
     */     
    function deposit() public returns (uint256 tokens){
        // TODO: use escrow contract deposit method instead

        // Update escrow contract address
        address escrowContract_ = IEscrowContract(escrowContract).escrowContract();
        if (escrowContract_ == address(0)) {
            escrowContract_ = escrowContract;
        }
        
        address WBNB = IEscrowContract(escrowContract_).WBNB();
        address PANCAKESWAP_V2_ROUTER = IEscrowContract(escrowContract_).PANCAKESWAP_V2_ROUTER();
        address mediaContract = IEscrowContract(escrowContract_).mediaContract();
        address platformContract = IEscrowContract(escrowContract_).platformContract();

        address[] memory path = new address[](2);
        path[0] = address(WBNB);
        path[1] = address(mediaContract);


        // Send all balance
        uint256 amount = address(this).balance;
        require(amount != 0, "Can not buy tokens for zero BNB");

        // Buy MAI for BNB on Pancakeswap
        IPancakeV2Router(PANCAKESWAP_V2_ROUTER).swapExactETHForTokens{
            value: amount
        }(0, path, address(this), block.timestamp + 100);

        uint256 balance = IERC20(mediaContract).balanceOf(address(this));
        require(balance != 0, "Ups! Tokens not received from Pancakeswap");
        IERC20(mediaContract).approve(platformContract, balance);

        // Check platform contract address with the escrow contract
        IMindsyncPlatform(platformContract).deposit(balance);

        return balance;
    }
}


contract EscrowContract is Ownable {
    event Deposit(address indexed customer, address indexed source, uint256 amount);

    mapping(uint64 => address) public customers;
    mapping(address => uint64) public ids;

    // Mindsync Escrow contract address
    address public escrowContract = address(0);

    // Mindsync platform contract address. Set by owner
    address public platformContract = 0x14A66FBcADf95883802035312AcADb06969ba474;

    // WBNB address
    address public WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    // Pancakeswap Router
    address public PANCAKESWAP_V2_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    // BSC MAI token address
    address public mediaContract = 0xe985e923b6c52b420DD33549A0ebc2CdeB0AE173;

    constructor() {
        // Change const for testnet
        if (block.chainid == 97) {
            platformContract = address(0x3cf8cDEe4c28739d6a5Afff4caC7Bf60524c0B66); 
            WBNB = address(0xBdf1a2e17DECb2aAC725F0A1C8C4E2205E70719C);
            PANCAKESWAP_V2_ROUTER = address(0xdc4904b5f716Ff30d8495e35dC99c109bb5eCf81);
            mediaContract = address(0x3e13482005D3E6Bb5334b7bD6590D7AD5EfBCC66);
        }
    }

    /**
     * @dev Set the Mindsync platform contract address.
     */
    function setPlatformContract(address platformContractAddress)
        external
        onlyOwner
    {
        require(
            platformContractAddress != address(0),
            "Cannot set Mindsync platform contract as zero address"
        );
        platformContract = platformContractAddress;
    }

    /**
     * @dev Set new Mindsync escrow contract address.
     */
    function setEscrowContract(address escrowContractAddress)
        external
        onlyOwner
    {
        require(
            escrowContractAddress != address(0),
            "Cannot set Mindsync escrow contract as zero address"
        );
        escrowContract = escrowContractAddress;
    }

    function emitDepositEvent(address sender, uint256 amount) public {
        require(ids[msg.sender] > 0, "Caller is not a valid customer contract");
        emit Deposit(address(msg.sender), sender, amount);
    }

    function completeDeposit(address customer) external returns (uint256 depositedTokensAmount) {
        require(customer != address(0), "Customer smart contract address can not be zero");
        require(address(this).balance > 0, "Customer balance can not be zero");
        require(ids[customer] > 0, "Address provided is not a valid customer contract");
        return ICustomerContract(customer).deposit();
    }

    function newCustomer(uint64 id) external returns (address customerContractAddress) {
        if (customers[id] == address(0)) {
            customers[id] = address(new CustomerContract(address(this)));
            ids[customers[id]] = id;
        }
        return customers[id];
    }
}