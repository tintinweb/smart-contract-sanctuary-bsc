// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Owner.sol";

contract QTKMIco is Owner {
    ERC20 public TKMToken;
    address public Operator; // 토큰 분배할 지갑 주소

    // ico유저, 토큰 판매 수량(락 물량 포함)
    event Ico(address indexed from, uint256 amount);

    // 락 토큰 찾아가기. order = 1 ~ 18, amount = 1회 찾아간 수량
    event IcoClaim(address indexed from, uint8 order, uint256 amount);

    /////////////////////////////////////////////////////
    // ico
    // ico 일정
    struct icoOrder {
        uint256 totalAmount; // 이번 회차에 판매할 토큰 제한 수량
        uint256 sellAmount; // 이번 회차에 판매 완료한 수량
        uint256 tokenMultiply; // 코인 * {배수} = 3KM
        uint256 limitPerUser; // 이번 회차에 유저당 구입 가능 토큰 제한 수량
        uint256 startTime; // 시작 시간
        uint256 endTime; // 종료 시간
        mapping(address => uint256) tokenPerUser; // 이번 회차에 유저별 구입한 토큰 수량
    }
    // 1, 2, 3차 => ico 정보
    mapping(uint8 => icoOrder) public icoOrders;
    // 실제 구매한 토큰 수량에서 바로 보내줄 비율
    uint8 private tge_;
    // 현재 진행중인 회차
    uint8 public order;

    /////////////////////////////////////////////////////
    // 락 토큰 보관 및 지급
    // 토큰 상장 후 최초로 찾아갈 수 있는 시간
    uint256 public tokenClaimTime;
    // 상장 후 최초 풀리는 개월 수 이후에 지급할 횟수 별 날짜 단위
    uint8 public releaseOrderDay = 30;
    // 상장 후 최초 풀리는 개월 수 이후에 지급할 횟수
    uint8 public releaseOrderCount = 24;
    // 유저별 남은 토큰. 1회 수량
    mapping(address => uint256) public lockedTokens;
    // 유저별 락 토큰 지급 상태
    mapping(address => mapping(uint8 => bool)) public lockedTokenTransfer;

    constructor(address _TKMToken, address _Operator) {
        TKMToken = ERC20(payable(_TKMToken));
        Operator = _Operator;
        tge_ = 10; // ico진행 시 유저 지갑에 보낼 토큰 비율
        order = 1;
    }

    // ico 회차별 설정
    function setIcoOrder(
        uint8 _order,
        uint256 _totalAmount,
        uint256 _tokenMultiply,
        uint256 _limitPerUser,
        uint256 _startTime,
        uint256 _endTime
    ) public onlyOwner {
        require(_order > 0, "TKMIco order be greater than zero");
        // require(_order < 4, "TKMIco order be less than four");

        require(_startTime > block.timestamp, "TKMIco _startTime is under now");
        require(_endTime > block.timestamp, "TKMIco _endTime is under now");
        require(_endTime > _startTime, "TKMIco _endTime is under _startTime");

        // 없으면 기록
        if (0 == icoOrders[_order].totalAmount) {
            icoOrder storage newOrder = icoOrders[_order];
            newOrder.totalAmount = _totalAmount;
            newOrder.sellAmount = 0;
            newOrder.tokenMultiply = _tokenMultiply;
            newOrder.limitPerUser = _limitPerUser;
            newOrder.startTime = _startTime;
            newOrder.endTime = _endTime;
            return;
        }

        // 전체 수량 제외하고 수정 가능
        icoOrders[_order].tokenMultiply = _tokenMultiply;
        icoOrders[_order].limitPerUser = _limitPerUser;
        icoOrders[_order].startTime = _startTime;
        icoOrders[_order].endTime = _endTime;
    }

    // ico 차수 증가. 진행중인 회차 종료시 호출해야 함
    function incOrder() public onlyOwner {
        // 진행중인 차수의 미판매 수량 다음으로 넘기기
        uint256 remainTokenAmount = icoOrders[order].totalAmount - icoOrders[order].sellAmount;

        // 진행중인 차수 증가
        order++;

        // 다음 회차에 증가
        icoOrders[order].totalAmount += remainTokenAmount;
    }

/*
    struct icoOrder {
        uint256 totalAmount; // 이번 회차에 판매할 토큰 제한 수량
        uint256 sellAmount; // 이번 회차에 판매 완료한 수량
        uint256 tokenMultiply; // // 코인 * {배수} = 3KM
        uint256 limitPerUser; // 이번 회차에 유저당 구입 가능 토큰 제한 수량
        uint256 startTime; // 시작 시간
        uint256 endTime; // 종료 시간
        mapping(address => uint256) tokenPerUser; // 이번 회차에 유저별 구입한 토큰 수량
    }
*/
    // ORK 토큰 요청
    function ico() public payable {
        // 진행중인지 체크
        require(0 < icoOrders[order].totalAmount, "TKMIco: ico is empty");
        // 코인 수량 체크
        require(1 ether <= msg.value, "TKMIco: ico value is less than 1 ether");
        // 기간 체크
        require(icoOrders[order].startTime <= block.timestamp, "TKMIco: ico is not running");
        require(icoOrders[order].endTime >= block.timestamp, "TKMIco: ico was ended");

        // 구매 토큰
        uint256 validBuyToken = icoOrders[order].tokenMultiply * msg.value;

        // 남은 토큰
        uint256 validSellToken = icoOrders[order].totalAmount - icoOrders[order].sellAmount;
        // 현재 판매한 수량 증가
        icoOrders[order].sellAmount += validBuyToken;

        // 남은 토큰 비교
        require(validSellToken >= validBuyToken, "TKMIco: ico not enough token");

        // 유저의 현재 구매 토큰으로 구매 가능한 수량 체크
        uint256 boughtToken = icoOrders[order].tokenPerUser[msg.sender];
        // 유저의 구매 내역 증가
        icoOrders[order].tokenPerUser[msg.sender] += validBuyToken;
        require(icoOrders[order].limitPerUser >= boughtToken + validBuyToken, "TKMIco: ico buying token is overflow");

        // 비율 계산
        uint256 sendToken = (validBuyToken * tge_) / 100;
        // 남은 토큰
        uint256 remainToken = validBuyToken - sendToken;
        lockedTokens[msg.sender] += remainToken / releaseOrderCount;

        // ico 요청자에게 토큰 전송
        require(
            TKMToken.transferFrom(Operator, msg.sender, sendToken),
            "TKMIco: unable to send token, recipient may have reverted"
        );

        emit Ico(msg.sender, validBuyToken);
    }

    // 토큰 상장 후 최초로 찾아갈 수 있는 시간 설정. 한번만 가능함
    function setTokenClaimTime(uint256 _tokenClaimTime) public onlyOwner {
        require(0 == tokenClaimTime, "TKMIco: already set token claim time");
        tokenClaimTime = _tokenClaimTime;
    }
/*
    // 토큰 상장 후 최초로 찾아갈 수 있는 시간
    uint256 private tokenClaimTime;
    // 상장 후 최초 풀리는 개월 수 이후에 지급할 횟수 별 날짜 단위
    uint8 public releaseOrderDay = 30;
    // 상장 후 최초 풀리는 개월 수 이후에 지급할 횟수
    uint8 public releaseOrderCount = 18;
    // 유저별 남은 토큰. 1회 수량
    mapping(address => uint256) public lockedTokens;
    // 유저별 락 토큰 지급 상태
    mapping(address => mapping(uint8 => bool)) public lockedTokenTransfer;
*/
    // 락상태 토큰 전송 요청 기능
    function icoClaim(uint8 claimOrder) public {
        //최초로 찾아갈 수 있는 시간이 없으면 실패
        require(0 < tokenClaimTime, "TKMIco: icoClaim invalid token claim time");
        // order 값 체크
        require(0 < claimOrder && releaseOrderCount >= claimOrder, "TKMIco: icoClaim invalid order");
        // 이미 지급했는지 확인
        require(false == lockedTokenTransfer[msg.sender][claimOrder], "TKMIco: icoClaim already claimed");
        // 지급 설정
        lockedTokenTransfer[msg.sender][claimOrder] = true;
        // 날짜 체크
        // uint256 releaseTime = tokenClaimTime + ((releaseOrderDay * (claimOrder - 1)) * 1 days);
        uint256 releaseTime = tokenClaimTime + ((15 * (claimOrder - 1)) * 60);     // 15분
        require(block.timestamp > releaseTime, "TKMIco: icoClaim time is not come");
        // 지급 토큰 수량
        uint256 tokenAmount = lockedTokens[msg.sender];
        require(tokenAmount > 0, "TKMIco: icoClaim token amount is zero");
        // 지급 처리
        require(
            TKMToken.transferFrom(Operator, msg.sender, tokenAmount),
            "TKMIco: icoClaim unable to send token, recipient may have reverted"
        );

        emit IcoClaim(msg.sender, claimOrder, tokenAmount);
    }

    // ico 완료 후 지정한 주소로 보관 중인 이더 출금
    function withdrawEth(address to) public onlyOwner {
        require(to != address(0), "TKMIco: transfer to the zero address");
        // 해당 주소로 보관 중인 이더 전체 전송
        address payable receiver = payable(to);
        receiver.transfer(address(this).balance);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

contract Owner {
    event ChangeOwner(address indexed from, address indexed to);

    address payable public owner;

    constructor() {
        owner = payable(msg.sender);
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the contract owner can call this function"
        );
        _;
    }

    function changeOwner(address payable newOwner_) public onlyOwner {
        require(newOwner_ != address(0), "not zero address for new owner");
        owner = newOwner_;
        emit ChangeOwner(msg.sender, newOwner_);
    }
}

contract Minter {
    event ChangeMinter(address indexed from, address indexed to);

    address public minter;

    constructor(address minter_) {
        minter = minter_;
    }

    modifier onlyMinter() {
        require(
            msg.sender == minter,
            "Only the contract minter can call this function"
        );
        _;
    }

    function changeMinter(address newMinter_) public onlyMinter {
        require(newMinter_ != address(0), "not zero address for new minter");
        minter = newMinter_;
        emit ChangeMinter(msg.sender, newMinter_);
    }
}

// 컨트랙트 제거. 사용할 일이 있을지..
contract Mortal is Owner {
    function destroy() public virtual onlyOwner {
        selfdestruct(owner);
    }
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}