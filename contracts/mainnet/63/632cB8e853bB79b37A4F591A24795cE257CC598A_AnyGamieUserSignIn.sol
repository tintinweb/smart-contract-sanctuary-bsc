/**
 *Submitted for verification at BscScan.com on 2023-01-20
*/

pragma solidity 0.5.16;

interface AnyGamieSignIn {
    /**
     * @dev Returns the Journey.
     */
    function getSignIn(address addr,uint256 index)
        external
        view
        returns (
            uint256,
            address,
            uint16,
            uint16,
            uint16,
            uint16,
            uint16,
            uint16
        );

    
    event NewUserSignIn(
        address indexed from,
        uint16 pointAdd, //积分增加
        uint16 pointUsed, //积分消耗
        uint16 playGameCount, //游戏次数
        uint16 fiatExchange,//法币兑换 单位美分
        uint16 USDTExchangeIGM, //ustd兑换IGM (单位U)
        uint16 IGMExchangeUSDT //IGM兑换ustd (单位U)
    );
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract AnyGamieUserSignIn is Context, AnyGamieSignIn, Ownable {
    mapping(address => uint256) private _balances;

    // SignIn结构体
    struct SignIn {
        address from; // 用户钱包地址
        uint16 pointAdd; //积分增加
        uint16 pointUsed; //积分消耗
        uint16 playGameCount; //游戏次数
        uint16 fiatExchange; //法币兑换 单位美分
        uint16 USDTExchangeIGM; //ustd兑换IGM (单位U)
        uint16 IGMExchangeUSDT; //IGM兑换ustd (单位U)
    }

    mapping(address => SignIn[]) private _signin;

    /**
     * 写入签到的方法
     */
    function setSignIn(
        uint16 pointAdd,
        uint16 pointUsed,
        uint16 playGameCount,
        uint16 fiatExchange,
        uint16 USDTExchangeIGM,
        uint16 IGMExchangeUSDT
    ) public returns (bool) {
        _signin[msg.sender].push(
            SignIn({
                from: msg.sender,
                pointAdd: pointAdd,
                pointUsed: pointUsed,
                playGameCount: playGameCount,
                fiatExchange: fiatExchange,
                USDTExchangeIGM: USDTExchangeIGM,
                IGMExchangeUSDT: IGMExchangeUSDT
            })
        );

        emit NewUserSignIn(
            msg.sender,
            pointAdd,
            pointUsed,
            playGameCount,
            fiatExchange,
            USDTExchangeIGM,
            IGMExchangeUSDT);
        return true;
    }

    /**
     * 获取指定下标签到的方法
     */
    function getSignIn(address addr,uint256 index)
        public
        view
        returns (
            uint256,
            address,
            uint16,
            uint16,
            uint16,
            uint16,
            uint16,
            uint16
        )
    {
        if (_signin[addr].length == 0 ) {
            return (0, addr, 0, 0, 0, 0, 0, 0);
        } else {
            SignIn storage result = _signin[addr][index];
            return (
                _signin[addr].length,
                result.from,
                result.pointAdd,
                result.pointUsed,
                result.playGameCount,
                result.fiatExchange,
                result.USDTExchangeIGM,
                result.IGMExchangeUSDT
            );
        }
    }

    constructor() public {}

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address) {
        return owner();
    }
}