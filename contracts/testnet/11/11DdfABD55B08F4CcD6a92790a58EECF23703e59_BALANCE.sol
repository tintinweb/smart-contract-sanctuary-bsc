/**
 *Submitted for verification at BscScan.com on 2023-02-14
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

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

    function burn(uint256 amount) external;

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

abstract contract ReentrancyGuard {
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
     * by making the `nonReentrant` function external, and make it call a
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

library SafeMath {
    /**
     * @dev Multiplies two numbers, throws on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
     * @dev Integer division of two numbers, truncating the quotient.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
     * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /* @dev Subtracts two numbers, else returns zero */
    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b > a) {
            return 0;
        } else {
            return a - b;
        }
    }

    /**
     * @dev Adds two numbers, throws on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

contract BALANCE is ReentrancyGuard {
    using SafeMath for uint256;

    /*==============================
    =            EVENTS            =
    ==============================*/
    event onTransformToken(
        address indexed user,
        uint256 amount,
        address token,
        uint256 timestamp
    );

    event onTransformNative(uint256 amount, address token, uint256 timestamp);
    event onBurnTokens(uint256 amount, address token, uint256 timestamp);
    event onReFiTokens(uint256 amount, address token, uint256 timestamp);
    event onVaultTokens(uint256 amount, address token, uint256 timestamp);
    event onFeeTokens(uint256 amount, address token, uint256 timestamp);

    /*=================================
     =            DATASETS            =
     ================================*/
    mapping(address => uint256) private tokenBalaces_;
    mapping(address => bool) private whiteListedTokens;

    /*=====================================
    =            CONFIGURABLES            =
    =====================================*/
    /// amount after ration calculation goes to fee wallet
    uint256 public reFiRatio = 330; // calculation over 1000
    uint256 public burnRatio = 330;
    uint256 public vaultRatio = 330;

    mapping(address => uint256) private toReFi;
    mapping(address => uint256) private toBurn;
    mapping(address => uint256) private toVault;
    mapping(address => uint256) private toFee;

    address private owner_;

    constructor() {
        owner_ = msg.sender;
    }

    modifier onlyOwner() {
        require(owner_ == msg.sender, "you are not owner");
        _;
    }

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
        /// if token whitelisted must use recovery functions
        require(!whiteListedTokens[_token], "use remove functions");
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
    /// @dev change refi wallet deposit ratio
    function changeReFiRatio(uint256 _ratio) external onlyOwner {
        require(_ratio > 0 && _ratio < 1000, "must big then zero");
        require(
            _ratio + burnRatio + vaultRatio <= 1000,
            "must small then 1000"
        );
        reFiRatio = _ratio;
    }

    /// @dev change burn wallet deposit ratio
    function changeBurnRatio(uint256 _ratio) external onlyOwner {
        require(_ratio > 0 && _ratio < 1000, "must big then zero");
        require(
            _ratio + reFiRatio + vaultRatio <= 1000,
            "must small then 1000"
        );
        burnRatio = _ratio;
    }

    /// @dev change vault wallet deposit ratio
    function changeVaultRatio(uint256 _ratio) external onlyOwner {
        require(_ratio > 0 && _ratio < 1000, "must big then zero");
        require(_ratio + reFiRatio + burnRatio <= 1000, "must small then 1000");
        vaultRatio = _ratio;
    }

    /// @dev
    function addTokenToWhiteList(address _token) external onlyOwner {
        require(_token != address(0), "must big then zero");
        whiteListedTokens[_token] = true;
    }

    /// @dev
    function changeTokenWhiteListStatus(address _token, bool _status)
        external
        onlyOwner
    {
        require(whiteListedTokens[_token], "token not active");
        whiteListedTokens[_token] = _status;
    }

    /*=======================================
    =            PUBLIC FUNCTIONS           =
    =======================================*/
    function transformTokens(address _token, uint256 _amount)
        external
        nonReentrant
        returns (uint256)
    {
        require(whiteListedTokens[_token], "token not listed for reform");

        IBEP20(_token).transferFrom(msg.sender, address(this), _amount);

        (
            uint256 _burnFee,
            uint256 _vaultFee,
            uint256 _refiFee,
            uint256 _rest
        ) = allocateFees(_amount);

        toReFi[_token] += _refiFee;
        toBurn[_token] += _burnFee;
        toVault[_token] += _vaultFee;
        toFee[_token] += _rest;

        emit onTransformToken(msg.sender, _amount, _token, block.timestamp);

        tokenBalaces_[_token] += _amount;

        return _amount;
    }

    function removeReFiTokensFromReform(address _token, address _to) external {
        IBEP20(_token).transfer(_to, toReFi[_token]);
        emit onReFiTokens(toReFi[_token], _token, block.timestamp);
        toReFi[_token] = 0;
    }

    function removeVaultTokensFromReform(address _token, address _to) external {
        IBEP20(_token).transfer(_to, toVault[_token]);
        emit onVaultTokens(toVault[_token], _token, block.timestamp);
        toVault[_token] = 0;
    }

    function removeBurnTokensFromReform(address _token, address _to) external {
        IBEP20(_token).transfer(_to, toBurn[_token]);
        emit onBurnTokens(toBurn[_token], _token, block.timestamp);
        toBurn[_token] = 0;
    }

    function removeFeeTokensFromReform(address _token, address _to) external {
        IBEP20(_token).transfer(_to, toFee[_token]);
        emit onFeeTokens(toFee[_token], _token, block.timestamp);
        toFee[_token] = 0;
    }

    function getTokenAmounts(address _token)
        external
        view
        returns (uint256[4] memory)
    {
        uint256[4] memory amounts = [
            toReFi[_token],
            toBurn[_token],
            toVault[_token],
            toFee[_token]
        ];

        return amounts;
    }

    /*==========================================
    =            INTERNAL FUNCTIONS            =
    ==========================================*/
    function allocateFees(uint256 amount)
        internal
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 _share = amount.div(1000);

        uint256 _burnFee = _share.mul(burnRatio); /// 33% of deposit
        uint256 _vaultFee = _share.mul(vaultRatio); /// 33% of deposit
        uint256 _refiFee = _share.mul(reFiRatio); /// 33% of deposit
        uint256 _rest = amount.safeSub(_refiFee + _burnFee + _vaultFee); // 100 - 99 = 1% of deposit

        return (_refiFee, _burnFee, _vaultFee, _rest);
    }
}