//SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

//hash : 0xaaded96499142ae5ac9998b22744ef1306a5a7dea1621b8123de379a4408da34
// ["a","b","c","d","e","f"]
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {LibraryUtils} from "./LibraryUtils.sol";

library GameUtils {
    /*
     *_length: 随机范围[0 - _length]
     *_nonce: 自增变化的值
     */
    function randNumber(uint256 _length, uint256 _nonce)
        internal
        view
        returns (uint256)
    {
        uint256 random = uint256(
            keccak256(
                abi.encodePacked(
                    _nonce,
                    block.timestamp,
                    block.difficulty,
                    msg.sender
                )
            )
        ) % _length;
        return random;
    }

    /*
     *获取一个hash
     */
    function getHash() internal view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    blockhash(block.number),
                    block.timestamp,
                    block.difficulty,
                    msg.sender
                )
            );
    }
}

contract CryptoGrid is ERC20, Ownable {
    // 所有字母集合
    string[26] public letterArr = [
        "A",
        "B",
        "C",
        "D",
        "E",
        "F",
        "G",
        "H",
        "I",
        "J",
        "K",
        "L",
        "M",
        "N",
        "O",
        "P",
        "Q",
        "R",
        "S",
        "T",
        "U",
        "V",
        "W",
        "X",
        "Y",
        "Z"
    ];

    // 记录一个玩家的游戏过程
    struct Record {
        // 当局游戏是否有效
        bool _status;
        // 游戏当前输入行数
        uint8 _row;
        // 当局游戏结果
        string[6] _gameResWords;
        // 游戏开始时间
        uint256 _startTime;
        // 结束时间
        uint256 _endTime;
    }
    // 玩家游戏列表
    mapping(address => mapping(bytes32 => Record)) public Records;

    // 个人信息
    struct InfoStru {
        // 上级地址
        address father;
        // 我的下级地址
        address[] sons;
        // 是否是代理
        bool isAgent;
        // 是否参与igo
        bool isIgo;
        // Igo amount
        uint256 igoAmount;
        // 赢
        uint256 winCount;
        // 输
        uint256 loseCount;
    }
    // 个人信息映射
    mapping(address => InfoStru) public PersonInfo;

    event checkRowEvent(
        bytes32 _hash,
        uint256[6] _positionInfo,
        address _sender
    );

    // 绑定邀请人事件
    event bindInviterEvent(address indexed _binder, address indexed _son);

    constructor() ERC20("Crypto Grid", "Grid") {
        _mint(msg.sender, 21000000 * 10**decimals());
    }

    function testHash() public view returns (bytes32) {
        return GameUtils.getHash();
    }

    // 开始游戏
    function StartInit() public returns (bytes32) {
        bytes32 _hash = GameUtils.getHash();
        string[6] memory _gameRandomWords = gameRandomWords();
        Records[msg.sender][_hash] = Record({
            _status: true,
            _row: 0,
            _gameResWords: _gameRandomWords,
            _startTime: block.timestamp,
            _endTime: 0
        });
        return _hash;
    }

    /*
     * 检查当前行对应字母位置
     * _word: 传来的当前行输入单词
     * _hash:游戏hash
     * _row: 当前进行验证行数
     */
    function chechRowRes(
        string[] memory _word,
        bytes32 _hash,
        uint256 _row
    ) public returns (uint256[6] memory) {
        Record memory gameInfo = Records[msg.sender][_hash];
        require(gameInfo._status, "Game Over");
        require(
            (_row + 1) > Records[msg.sender][_hash]._row,
            "Wrong number of rows validated"
        );
        require(_row >= 0 && _row <= 5, "Row overflow");
        string[6] memory gameResWords = gameInfo._gameResWords;
        uint256[6] memory positionInfo;
        string memory letter;
        for (uint256 i = 0; i < 6; i++) {
            letter = _word[i];
            (bool has, uint256 letterIndexOf) = LibraryUtils.arrIndexOf(
                gameResWords,
                letter
            );
            if (LibraryUtils.equal(letter, gameResWords[i])) {
                positionInfo[i] = 1;
            } else if (has && letterIndexOf != i) {
                positionInfo[i] = 2;
            } else {
                positionInfo[i] = 0;
            }
        }
        if (Records[msg.sender][_hash]._row >= 5) {
            Records[msg.sender][_hash]._status = false;
        }
        Records[msg.sender][_hash]._row += 1;
        emit checkRowEvent(_hash, positionInfo, msg.sender);
        return positionInfo;
    }

    // 获取对应地址的对应hash的结果
    function getGameRes(bytes32 _hash)
        public
        view
        onlyOwner
        returns (string[6] memory)
    {
        return Records[msg.sender][_hash]._gameResWords;
    }

    // 从26个字母中随机获取指定数量字符
    function gameRandomWords() public view returns (string[6] memory) {
        string[6] memory words;
        for (uint256 i = 0; i < 6; i++) {
            uint256 index = GameUtils.randNumber(25, i);
            words[i] = letterArr[index];
        }
        return words;
    }

    // 设置代理
    function setAgenter(address _agent) external onlyOwner {
        PersonInfo[_agent].isAgent = true;
    }

    // 判断代理
    function getAgenter(address _agent) external view onlyOwner returns (bool) {
        return PersonInfo[_agent].isAgent;
    }

    // 获取我的邀请人
    function getInviter() public view returns (address) {
        return PersonInfo[msg.sender].father;
    }

    // 绑定上级邀请人
    function bindInviter(address _binder) public returns (bool) {
        require(msg.sender != _binder, "Can't set myself as inviter");
        require(
            PersonInfo[msg.sender].father == address(0),
            "Inviter already bound"
        );
        _bindInviter(_binder);
        return true;
    }

    function _bindInviter(address _binder) internal onlyOwner {
        PersonInfo[msg.sender].father = _binder;
        PersonInfo[_binder].sons.push(msg.sender);
        emit bindInviterEvent(_binder, msg.sender);
    }

    // 测试绑定
    function bindSons(address _son) public onlyOwner {
        PersonInfo[msg.sender].sons.push(_son);
        PersonInfo[_son].isIgo = true;
    }

    // 设置某个地址的igo信息
    function setIgo(address _son, bool _isigo) public onlyOwner {
        PersonInfo[_son].isIgo = _isigo;
    }

    // 修改某个地址的上级
    function updateFatherInviter(address _son, address _father)
        external
        onlyOwner
    {
        require(PersonInfo[_son].father != address(0), "No superior inviter");
        PersonInfo[_son].father = address(0x0);
        uint256 arrLength = PersonInfo[_father].sons.length;
        uint256 sonAtFatherIndex = 0;
        for (uint256 index = 0; index <= arrLength; index++) {
            if (PersonInfo[_father].sons[index] == _son) {
                sonAtFatherIndex = index;
            }
        }
        delete PersonInfo[_father].sons[sonAtFatherIndex];
    }

    // 查询地址下有效的下级地址
    function querySon() public view returns (address[] memory) {
        address[] memory sons = PersonInfo[msg.sender].sons;
        uint256 sonsLength = sons.length;
        address[] memory returnSons = new address[](sonsLength);
        for (uint256 i = 0; i < sonsLength; i++) {
            address son = PersonInfo[msg.sender].sons[i];
            if (PersonInfo[son].isIgo) {
                returnSons[i] = son;
            }
        }
        return returnSons;
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

library LibraryUtils {
    /*
     * @dev 把字符串转为大写
     * @src 字符串
     */
    function toUppercase(string memory src)
        internal
        pure
        returns (string memory)
    {
        bytes memory srcb = bytes(src);
        for (uint256 i = 0; i < srcb.length; i++) {
            bytes1 b = srcb[i];
            if (b >= "a" && b <= "z") {
                b &= bytes1(0xDF);
                srcb[i] = b;
            }
        }
        return src;
    }

    /*
    *@dev 字符串转数组
    *@ss 字符串
    @one_adr_len 字符串长度
    */
    function ConvertString2Arr(string memory ss, uint256 one_adr_len)
        public
        pure
        returns (string[] memory)
    {
        bytes memory _ss = bytes(ss);
        uint256 len = _ss.length / one_adr_len;
        string[] memory arr = new string[](len);
        uint256 k = 0;
        for (uint256 i = 0; i < len; i++) {
            bytes memory item = new bytes(one_adr_len);
            for (uint256 j = 0; j < one_adr_len; j++) {
                item[j] = _ss[k++];
            }
            arr[i] = string(item);
        }
        return arr;
    }

    /*
     * @dev byte32转string
     * @x bytes32数据
     */
    function Bytes32ToString(bytes32 b32name)
        internal
        pure
        returns (string memory)
    {
        bytes memory bytesString = new bytes(32);
        // 定义一个变量记录字节数量
        uint256 charCount = 0;
        // 统计共有多少个字节数
        for (uint32 i = 0; i < 32; i++) {
            bytes1 char = bytes1(bytes32(uint256(b32name) * 2**(8 * i)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        // 初始化一动态数组，长度为charCount
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (uint256 i = 0; i < charCount; i++) {
            bytesStringTrimmed[i] = bytesString[i];
        }
        return string(bytesStringTrimmed);
    }

    /*
     *@dev 比较两个字符串是否相等，区分大小写
     *@self 当前字符
     *@other 另一字符
     */
    function equal(string memory self, string memory other)
        internal
        pure
        returns (bool)
    {
        bytes memory self_rep = bytes(self);
        bytes memory other_rep = bytes(other);

        if (self_rep.length != other_rep.length) {
            return false;
        }
        uint256 selfLen = self_rep.length;
        for (uint256 i = 0; i < selfLen; i++) {
            if (self_rep[i] != other_rep[i]) return false;
        }
        return true;
    }

    /*
     *@dev 查找字符串中是否含有子字符串
     *@src 字符串
     *@value 查找值
     *@offset 位移
     */
    function arrIndexOf(string[6] memory arr, string memory value)
        internal
        pure
        returns (bool, uint256)
    {
        for (uint256 i = 0; i < arr.length; i++) {
            if (equal(arr[i], value)) {
                return (true, i);
            }
        }
        return (false, 0);
    }
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
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

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
     * @dev Moves `amount` of tokens from `from` to `to`.
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