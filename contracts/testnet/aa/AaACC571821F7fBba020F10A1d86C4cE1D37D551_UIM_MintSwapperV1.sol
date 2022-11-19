/**
 *Submitted for verification at BscScan.com on 2022-11-18
*/

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

// File: contracts/UIMSwapper.sol


pragma solidity 0.8.17;



interface UIM_NFT {
    function mintItem(address owner, string memory tokenURI)
        external
        returns (uint256);
}

interface IPancakeRouter01 {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

contract UIM_MintSwapperV1 is Ownable {
    address public PANCAKE_ROUTER_ADDRESS;
    address public UIM_ORACLE_WALLET;
    address public UIM_NFT_CONTRACT;
    address public BUSD_CONTRACT;
    address public REWARD_COLLECTOR_ADDRESS;
    address public BURN_ADDRESS;
    uint256 public BURNING_PERCENTAGE = 15;

    uint256 UIM_CURRENCY = 1;
    uint256 BUSD_CURRENCY = 2;

    // Testnet
    address[2] PATH = [
        0xaB1a4d4f1D656d2450692D237fdD6C7f9146e814, // BUSD
        0xddb8A2dD40e996b7aDeCF383E99F8aa10C45b87e // UIM TOKEN
    ];

    // Mainnet
    // address[2] PATH = [
    //     0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56, // BUSD
    //     0x1BB132D6039b81FaEdc524a30E52586b6Ca15f48 // UIM TOKEN
    // ];

    event MintOrderRequest(
        address initiator,
        uint256 mintableItemsIndex,
        uint256 currency
    );

    event MintOrderExecuted(
        uint256 mintPrice,
        uint256 currency,
        uint256 tokenId,
        address minter,
        string tokenURI
    );

    event ContractSettingsChanged(
        address pancakeRouterAddress,
        address uimOracleWallet,
        address uimNftContract,
        address busdContract,
        address rewardCollectorAddress,
        address burnAddress
    );

    // Utility functions

    constructor() {

        // Testnet config
        PANCAKE_ROUTER_ADDRESS = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
        UIM_ORACLE_WALLET = 0x311a5d5383A18F775994074F31d74B0D72C604DD;
        UIM_NFT_CONTRACT = 0x900Ce4DdFea39997f37c29ca22e1bB4f23808E27;
        BUSD_CONTRACT = 0xaB1a4d4f1D656d2450692D237fdD6C7f9146e814;
        REWARD_COLLECTOR_ADDRESS = 0xb72838Cc39De2e1F59740d868C8179c4d103A095;
        BURN_ADDRESS = 0x0000000000000000000000000000000000000001;
        // Initial config
        // PANCAKE_ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // UIM_ORACLE_WALLET = 0x44ff08941e7D25e2CB75De8d1444DE5F5611905A;
        // UIM_NFT_CONTRACT = 0x23613A2Aa83Db43d397B4d494B576dEa85848ba0;
        // BUSD_CONTRACT = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        // REWARD_COLLECTOR_ADDRESS = 0x44ff08941e7D25e2CB75De8d1444DE5F5611905A;
        // BURN_ADDRESS = 0x0000000000000000000000000000000000000001;
    }

    function changeContractSettings(
        address _PANCAKE_ROUTER_ADDRESS,
        address _UIM_ORACLE_WALLET,
        address _UIM_NFT_CONTRACT,
        address _BUSD_CONTRACT,
        address _REWARD_COLLECTOR_ADDRESS,
        address _BURN_ADDRESS,
        uint256 _BURNING_PERCENTAGE
    ) external onlyOwner {
        PANCAKE_ROUTER_ADDRESS = _PANCAKE_ROUTER_ADDRESS;
        UIM_ORACLE_WALLET = _UIM_ORACLE_WALLET;
        UIM_NFT_CONTRACT = _UIM_NFT_CONTRACT;
        BUSD_CONTRACT = _BUSD_CONTRACT;
        REWARD_COLLECTOR_ADDRESS = _REWARD_COLLECTOR_ADDRESS;
        BURN_ADDRESS = _BURN_ADDRESS;
        BURNING_PERCENTAGE = _BURNING_PERCENTAGE;

        emit ContractSettingsChanged(
            PANCAKE_ROUTER_ADDRESS,
            UIM_ORACLE_WALLET,
            UIM_NFT_CONTRACT,
            BUSD_CONTRACT,
            REWARD_COLLECTOR_ADDRESS,
            BURN_ADDRESS
        );
    }

    // Utility functions

    // Calculate x * y / scale rounding down.
    function mulScale(
        uint256 x,
        uint256 y,
        uint128 scale
    ) internal pure returns (uint256) {
        uint256 a = x / scale;
        uint256 b = x % scale;
        uint256 c = y / scale;
        uint256 d = y % scale;

        return a * c * scale + a * d + b * c + (b * d) / scale;
    }

    function calculateMinimumToRecieve(uint256 amount, uint256 slippageFee)
        internal
        pure
        returns (uint256)
    {
        uint256 fee = mulScale(slippageFee, amount, 1000);
        uint256 remaining = amount - fee;
        return remaining;
    }


    function swapContractBusdBalanceToUimAndBurn(
        uint256 busdAmountToSwap,
        address remainingFundsDestination
    ) internal returns (bool) {

        IPancakeRouter01 Router = IPancakeRouter01(PANCAKE_ROUTER_ADDRESS);
        IERC20 BUSD = IERC20(PATH[0]);
        IERC20 UIM = IERC20(PATH[1]);

        require(
            BUSD.approve(PANCAKE_ROUTER_ADDRESS, busdAmountToSwap),
            "approve failed."
        );

        uint256 minToRecieve = calculateMinimumToRecieve(busdAmountToSwap, 8);
        address[] memory path = new address[](2);
        path[0] = PATH[0];
        path[1] = PATH[1];

        Router.swapExactTokensForTokens(
            busdAmountToSwap,
            minToRecieve,
            path,
            address(this),
            block.timestamp + 1080
        );

        uint256 amountToBurn = mulScale(
            BURNING_PERCENTAGE,
            UIM.balanceOf(address(this)),
            100
        );
        uint256 remaining = UIM.balanceOf(address(this)) - amountToBurn;

        UIM.transfer(BURN_ADDRESS, amountToBurn);
        UIM.transfer(remainingFundsDestination, remaining);
        return true;
    }

    function swapAllContractBusdBalanceToUimAndBurn(
    ) internal returns (bool) {

        IPancakeRouter01 Router = IPancakeRouter01(PANCAKE_ROUTER_ADDRESS);
        IERC20 BUSD = IERC20(PATH[0]);
        IERC20 UIM = IERC20(PATH[1]);

        uint256 busdAmountToSwap = BUSD.balanceOf(address(this));

        require(
            BUSD.approve(PANCAKE_ROUTER_ADDRESS, busdAmountToSwap),
            "approve failed."
        );

        uint256 minToRecieve = calculateMinimumToRecieve(busdAmountToSwap, 8);
        address[] memory path = new address[](2);
        path[0] = PATH[0];
        path[1] = PATH[1];

        Router.swapExactTokensForTokens(
            busdAmountToSwap,
            minToRecieve,
            path,
            address(this),
            block.timestamp + 1080
        );

        UIM.transfer(BURN_ADDRESS, UIM.balanceOf(address(this)));
        return true;
    }
    
    function mintItemUIMRequest(uint256 _mintableItemsIndex)
        external
        returns (bool)
    {
        emit MintOrderRequest(msg.sender, _mintableItemsIndex, UIM_CURRENCY);
        return true;
    }

    function mintItemBUSDRequest(uint256 _mintableItemsIndex)
        external
        returns (bool)
    {
        emit MintOrderRequest(msg.sender, _mintableItemsIndex, BUSD_CURRENCY);
        return true;
    }

    function executeMintItem(
        string memory tokenURI,
        address destination,
        uint256 amount,
        uint256 currency
    ) external {
      
        require(
            msg.sender == UIM_ORACLE_WALLET,
            "Only oracle can mint via this contract"
        );

        require(
            currency == UIM_CURRENCY || currency == BUSD_CURRENCY,
            "Currency ID invalid"
        );

        IERC20 BUSD = IERC20(PATH[0]);
        IERC20 UIM = IERC20(PATH[1]);
        UIM_NFT UimNftContract = UIM_NFT(UIM_NFT_CONTRACT);

        if (currency == UIM_CURRENCY) {
            UIM.transferFrom(destination, address(this), amount);
            uint256 amountToBurn = mulScale(
                BURNING_PERCENTAGE,
                UIM.balanceOf(address(this)),
                100
            );
            uint256 remaining = UIM.balanceOf(address(this)) - amountToBurn;
            UIM.transfer(REWARD_COLLECTOR_ADDRESS, remaining);
            UIM.transfer(BURN_ADDRESS, amountToBurn);
        } else if (currency == BUSD_CURRENCY) {
            BUSD.transferFrom(destination, address(this), amount);
            uint256 amountToBurn = mulScale(
                BURNING_PERCENTAGE,
                BUSD.balanceOf(address(this)),
                100
            );
            uint256 remaining = BUSD.balanceOf(address(this)) - amountToBurn;
            BUSD.transfer(REWARD_COLLECTOR_ADDRESS, remaining);
            swapAllContractBusdBalanceToUimAndBurn();

        }


        uint256 newTokenId = UimNftContract.mintItem(destination, tokenURI);
        emit MintOrderExecuted(
            amount,
            currency,
            newTokenId,
            destination,
            tokenURI
        );
    }
}