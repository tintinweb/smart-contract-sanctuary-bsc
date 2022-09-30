/**
 *Submitted for verification at BscScan.com on 2022-09-30
*/

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

// email: [email protected]

abstract contract Owned {
    event OwnerUpdated(address indexed user, address indexed newOwner);
    address public owner;
    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");
        _;
    }

    constructor() {
        owner = msg.sender;
        emit OwnerUpdated(address(0), msg.sender);
    }

    function setOwner(address newOwner) public virtual onlyOwner {
        owner = newOwner;
        emit OwnerUpdated(msg.sender, newOwner);
    }
}

contract ExcludedFromFeeList is Owned {
    mapping(address => bool) internal _isExcludedFromFee;

    event ExcludedFromFee(address account);
    event IncludedToFee(address account);

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
        emit ExcludedFromFee(account);
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
        emit IncludedToFee(account);
    }

    function excludeMultipleAccountsFromFee(address[] calldata accounts)
        public
        onlyOwner
    {
        uint8 len = uint8(accounts.length);
        for (uint8 i = 0; i < len; ) {
            _isExcludedFromFee[accounts[i]] = true;
            unchecked {
                ++i;
            }
        }
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router {
    function factory() external pure returns (address);
}

abstract contract DexBase {
    address public immutable uniswapV2Pair;
    address public constant USDT = 0x55d398326f99059fF775485246999027B3197955;

    constructor() {
        IUniswapV2Router uniswapV2Router = IUniswapV2Router(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
                address(this),
                USDT
            );
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}

abstract contract ERC20 {
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );
    string public name;
    string public symbol;
    uint8 public immutable decimals;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        returns (bool)
    {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount)
        public
        virtual
        returns (bool)
    {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max)
            allowance[from][msg.sender] = allowed - amount;

        _transfer(from, to, amount);
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        balanceOf[from] -= amount;
        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }
        emit Transfer(from, to, amount);
    }

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}

abstract contract MarketFee is Owned, DexBase, ERC20 {
    address constant communityAddr = 0x9604594a7bcc8B721A58860305AF14177a17Ad38; //生态建设5%
    address constant fundAddr = 0xe2a3E88a34224D0028c41fdd10c4Ef200B62aA07; // 基金会3%
    address constant commerAddr = 0xb6dc6667BEF6B00328d3EcB40bd35b4497c56923; // 商学院3%
    address constant studioAddr = 0x3774a996671f2853A93762a6cdcd8A9e4c7EB31A; // 工作室2%
    address constant DEAD = address(0xdead); //销毁2%
    bool public tradingStatus;

    uint256 constant burnBuyFee = 3;
    uint256 constant inviterBuyFee = 2;

    uint256 constant communitySellFee = 5;
    uint256 constant fundSellFee = 3;
    uint256 constant commerSellFee = 3;
    uint256 constant studioSellFee = 2;
    uint256 constant burnSellFee = 2;

    mapping(address => address) public inviter;

    function updateTradingStatus(bool _status) external onlyOwner {
        tradingStatus = _status;
    }

    function _takeMarketing(
        address sender,
        uint256 amount,
        address recipient
    ) internal returns (uint256) {
        // sell
        if (recipient == uniswapV2Pair) {
            require(tradingStatus, "trading open");
            uint256 communityAmount = (amount * communitySellFee) / 100;
            uint256 fundAmount = (amount * fundSellFee) / 100;
            uint256 commerAmount = fundAmount;
            uint256 studioAmount = (amount * studioSellFee) / 100;
            uint256 burnAmount = studioAmount;

            super._transfer(sender, communityAddr, communityAmount);
            super._transfer(sender, fundAddr, fundAmount);
            super._transfer(sender, commerAddr, commerAmount);
            super._transfer(sender, studioAddr, studioAmount);
            super._transfer(sender, DEAD, burnAmount);
            return
                communityAmount +
                fundAmount +
                commerAmount +
                studioAmount +
                burnAmount;
        } else if (sender == uniswapV2Pair) {
            // buy
            require(tradingStatus, "trading open");
            uint256 burnAmount = (amount * burnBuyFee) / 100;
            super._transfer(sender, DEAD, burnAmount);

            uint256 inviterAmount = (amount * inviterBuyFee) / 100;
            address cur = recipient;
            cur = inviter[cur];
            if (cur == address(0)) {
                cur = studioAddr;
            }
            super._transfer(sender, cur, inviterAmount);
            return burnAmount + inviterAmount;
        } else {
            uint256 __amount = (amount * 5) / 100;
            super._transfer(sender, communityAddr, __amount);

            return __amount;
        }
    }
}

contract HSE_Token is ExcludedFromFeeList, MarketFee {
    constructor() ERC20("HSE", "HSE", 18) MarketFee() {
        _mint(msg.sender, 20000_0000 * 1e18);
        excludeFromFee(msg.sender);
    }

    function shouldTakeFee(address sender, address recipient)
        internal
        view
        returns (bool)
    {
        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            return false;
        }
        return true;
    }

    function takeFee(
        address sender,
        uint256 amount,
        address recipient
    ) internal returns (uint256) {
        uint256 marketingAmount = _takeMarketing(sender, amount, recipient);
        return amount - marketingAmount;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {
        bool shouldInvite = (balanceOf[recipient] == 0 &&
            inviter[recipient] == address(0) &&
            !isContract(sender) &&
            !isContract(recipient));

        if (shouldTakeFee(sender, recipient)) {
            uint256 transferAmount = takeFee(sender, amount, recipient);
            super._transfer(sender, recipient, transferAmount);
        } else {
            super._transfer(sender, recipient, amount);
        }

        if (shouldInvite) {
            inviter[recipient] = sender;
        }
    }
}