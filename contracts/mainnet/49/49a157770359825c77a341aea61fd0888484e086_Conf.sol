/**
 *Submitted for verification at BscScan.com on 2022-12-30
*/

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

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}



pragma solidity ^0.8.0;


/**
 * @dev Interface of ERC20 & add permit function
 */
interface ICoin is IERC20Metadata {
    function permit(address owner, address to, uint256 amount, bytes memory signature) external;
}



pragma solidity ^0.8.0;

interface IConf {

    function broker() external view returns (address);

    function feeAddr() external view returns (address);

    function passcardAddr() external view returns (address);

    function ronAddr() external view returns (address);

    function conAddr() external view returns (address);

    function heroAddr() external view returns (address);

    function armAddr() external view returns (address);

    function marketAddr() external view returns (address);

    function usdtRON() external view returns (uint256);

    function usdtCON() external view returns (uint256);
}



pragma solidity ^0.8.0;

/**
 * @dev Interface for Admin
 * This realize multi-sign audit
 */
interface IAdmin {
    function mustAudited(address to) external view;
    function mustMaster(address addr) external view;
    function isMaster(address addr) external view returns (bool);
    function isAdmin(address addr) external view returns (bool);
    function isAuditor(address addr) external view returns (bool);
    function inAddress(address addr) external view returns (bool);
    function audit(bytes memory bkdata, string memory descr) external;
    function auditMsg(address from, address to) external view returns(bytes32);
    function checkSignature(bytes32 message, bytes[] memory signatures) external view returns (bool);
    function addressToString(address _address) external pure returns(string memory);
}



pragma solidity ^0.8.0;



/**
 * @title Registery data
 * proxy at bsctest: 0x726403ca41EBd77B722575919D637D503b6B41F7
 * proxy at bscmain: 0x4420BfC6CEbf9b54E43818203D41f46009C4732f
 */
contract Conf is IConf {

    // main
    IAdmin public constant Admin =
        IAdmin(0x32a5D69F59dE8271cF5fB9F613d5487a713924b8);

    address public override constant feeAddr = 0x8b328764025F81B50e4aB1C5ECEEBe23909252DE;
    address public override constant ronAddr = 0x59Dea8bb448b5167fB1cC6380A40a088588aa6C1;
    address public override constant conAddr = 0xE1fc1e1C7e65764Df214bf0A7c55f39bCe89D752;
    address public override constant heroAddr = 0x25790a8EaB7De8754FccEa647739BD3D20d91681;
    address public override constant armAddr = 0x5EA2bd96E08367F24F2CAc20e87f7EBaC62CC413;
    address public override constant passcardAddr = 0x5b936dCb112eeD8EBAE436d212342eFeE19E1859;
    address public override constant marketAddr = 0x4fC1c45f9e48a95cd9B6124375D16145BB634E23;
    address public override constant broker = 0x1D78064b9Bb8986DdaD3b537a5C5621645611177;

    uint256 internal _usdtron; // 1usdt = ron?
    uint256 internal _usdtcon; // 1usdt = con?

    modifier onlyMaster() {
        Admin.mustMaster(msg.sender);
        _;
    }

    /**
     * @dev init the data
     * onlyone
     */
    function init() public onlyMaster {
        if (_usdtron == 0) {
            _usdtron = 10 ** ICoin(ronAddr).decimals();
            _usdtcon = 10 ** ICoin(conAddr).decimals();
        }
    }

    // 1 usdt => ron amount
    function usdtRON() external view override returns (uint256) {
        return _usdtron;
    }

    // 1 usdt => con amount
    function usdtCON() external view override returns (uint256) {
        return _usdtcon;
    }

    function setUsdtRON(uint256 amount, uint8 decimals) public onlyMaster {
        if (decimals == 0) {
            decimals = 1;
        }
        _usdtron = uint256(10 ** ICoin(ronAddr).decimals() / decimals * amount);
    }

    function setUsdtCON(uint256 amount, uint8 decimals) public onlyMaster {
        if (decimals == 0) {
            decimals = 1;
        }
        _usdtcon = uint256(10 ** ICoin(conAddr).decimals() / decimals * amount);
    }
}