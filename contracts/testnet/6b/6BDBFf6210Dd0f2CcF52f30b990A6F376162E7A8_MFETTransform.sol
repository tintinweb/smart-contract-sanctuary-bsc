/**
 *Submitted for verification at BscScan.com on 2022-11-16
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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

    function _msgValue() internal view virtual returns (uint256) {
        return msg.value;
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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
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
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract MFETTransform is Context, Ownable {
    /*=====================================
    =            CONFIGURABLES            =
    =====================================*/

    uint256 public minTransform = 1e10; // min transfrom amount of token MFET
    uint256 public minTransformNative = 1e16; // min transfrom amount of BNB
    uint256 public serviceFee = 1e15; // calculation with 0.001 BNB

    /*=================================
     =            DATASETS            =
     ================================*/
    mapping(address => uint256) private tokenTransformLedger_;
    mapping(address => uint256) private nativeTransformLedger_;

    uint256 private totalTransformToken_;
    uint256 private totalTransformNative_;
    uint256 private totalServiceFee_;

    IBEP20 private mfetT = IBEP20(0xe5C06Ed88c8cCE4667946FdA10ae2cb69dEaaA96);

    receive() external payable {}

    /*=======================================
    =            RECOVERY FUNCTIONS         =
    =======================================*/
    /// @dev BEP20 Token
    function recoverBEP20(
        address _token,
        uint256 _amount,
        address _to
    ) external onlyOwner {
        IBEP20(_token).transfer(_to, _amount);
    }

    /// @dev Native Token BNB
    function recoverBNB(address payable _to) public onlyOwner {
        require(address(this).balance > 0, "zero native balance");
        _to.transfer(address(this).balance);
    }

    /*=======================================
    =            CONSTANT FUNCTIONS         =
    =======================================*/
    /// @dev change min invest amount
    function changeMinTransformToken(uint8 _amount) public onlyOwner {
        require(_amount > 0, "must big then zero");
        minTransform = _amount;
    }

    /// @dev change min service fee of native
    function changeMinTransformNative(uint8 _amount) public onlyOwner {
        require(_amount > 0, "must big then zero");
        minTransformNative = _amount;
    }

    /// @dev change min service fee of token
    function changeServiceFee(uint8 _fee) public onlyOwner {
        require(_fee >= 1e9, "equal or biger then GWei");
        require(_fee <= 1e18, "equal or small then ether");
        serviceFee = _fee;
    }

    /*=======================================
    =            PUBLIC FUNCTIONS           =
    =======================================*/
    function transform(uint256 _amount) external payable returns (uint256) {
        require(_msgValue() == serviceFee, "you must pay service fee");
        require(_amount >= minTransform, "check min transform amount");

        transformTokens(_amount, _msgSender(), _msgValue());
        return _amount;
    }

    function transformNative() external payable {
        require(
            _msgValue() >= minTransformNative,
            "check min transform amount"
        );
        transformNative(_msgValue(), _msgSender());
    }

    function transformTokensFor(uint256 _amount, address _user)
        external
        payable
        returns (uint256)
    {
        require(_msgValue() == serviceFee, "you must pay service fee");
        require(_amount >= minTransform, "check min transform amount");

        transformTokens(_amount, _user, serviceFee);
        return _amount;
    }

    function transformNativeFor(address _user) external payable {
        require(
            _msgValue() >= minTransformNative,
            "check min transform amount"
        );
        transformNative(_msgValue(), _user);
    }

    /// @dev Retrieve the total transform amount
    function totalTransformToken() external view returns (uint256) {
        return totalTransformToken_;
    }

    /// @dev Retrieve the total transform amount
    function totalTransformNative() external view returns (uint256) {
        return totalTransformNative_;
    }

    /// @dev Retrieve the total service fee amount
    function totalServiceFeeCollected() external view returns (uint256) {
        return totalServiceFee_;
    }

    /// @dev Retrieve the token transform data of mfet token any single address.
    function totalTransformWithAddress(address _address)
        public
        view
        returns (uint256)
    {
        return tokenTransformLedger_[_address];
    }

    /// @dev Retrieve the token transform data of native token any single address.
    function totalTransformNativeWithAddress(address _address)
        public
        view
        returns (uint256)
    {
        return nativeTransformLedger_[_address];
    }

    /*==========================================
    =            INTERNAL FUNCTIONS            =
    ==========================================*/
    function transformTokens(
        uint256 _amount,
        address _user,
        uint256 _fee
    ) internal {
        tokenTransformLedger_[_user] += _amount;

        // add to globals
        totalTransformToken_ += _amount;
        totalServiceFee_ += _fee;

        //send to transform wallet
        mfetT.transferFrom(_msgSender(), address(this), _amount);
    }

    function transformNative(uint256 _amount, address _user) internal {
        // safe sub to calculate fee
        uint256 safeAmount = _amount - serviceFee;
        nativeTransformLedger_[_user] += safeAmount;

        // add to globals
        totalTransformNative_ += safeAmount;
        totalServiceFee_ += serviceFee;
    }
}