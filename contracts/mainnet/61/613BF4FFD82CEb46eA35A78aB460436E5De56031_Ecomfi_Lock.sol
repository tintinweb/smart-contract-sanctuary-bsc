// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);
}

interface IWETH is IERC20 {
    function deposit() external payable;

    function withdraw(uint256) external;
}

interface IFactory {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
}

interface IPresale {
    function userDeposit(uint256 _amount) external payable;

    function userWithdrawTokens() external;
}

interface IRouter {
    function factory() external pure returns (address);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);
}

library LEComFiSwap {
    IWETH private constant _weth =
        IWETH(address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c));

    bytes4 public constant SWAP_SELECTOR =
        bytes4(
            keccak256(
                bytes(
                    "swapExactTokensForTokens(uint256,uint256,address[],address,uint256)"
                )
            )
        );
    bytes4 public constant ADD_LIQ_SELECTOR =
        bytes4(
            keccak256(
                bytes(
                    "addLiquidity(address,address,uint256,uint256,uint256,uint256,address,uint256)"
                )
            )
        );
    bytes4 public constant REMOVE_LIQ_SELECTOR =
        bytes4(
            keccak256(
                bytes(
                    "removeLiquidity(address,address,uint256,uint256,uint256,address,uint256)"
                )
            )
        );
    bytes4 public constant TRANSFER_SELECTOR =
        bytes4(keccak256(bytes("transfer(address,uint256)")));

    function thisAddress() internal view returns (address) {
        return address(this);
    }

    function getPair(
        address router_,
        address token0_,
        address token1_
    ) public view returns (address) {
        address factory = IRouter(router_).factory();
        return IFactory(factory).getPair(token0_, token1_);
    }

    function transferToken(
        address token_,
        address to_,
        uint256 amount_
    ) internal returns (bool success) {
        (success, ) = token_.call(
            (abi.encodeWithSelector(TRANSFER_SELECTOR, to_, amount_))
        );
    }

    function transferBnb(address to_, uint256 amount_)
        internal
        returns (bool success)
    {
        (success, ) = to_.call{value: amount_}(new bytes(0));
    }

    function _approve(address token_, address to_) internal {
        if (IERC20(token_).allowance(address(this), to_) == 0) {
            IERC20(token_).approve(to_, ~uint256(0));
        }
    }

    function swap(
        address router_,
        address fromCurrency_,
        address toCurrency_,
        uint256 amount_,
        uint256 min_received_,
        address to_
    ) internal returns (bool success) {
        address[] memory path = new address[](2);
        path[0] = fromCurrency_;
        path[1] = toCurrency_;

        _approve(fromCurrency_, router_);

        (success, ) = router_.call(
            (
                abi.encodeWithSelector(
                    SWAP_SELECTOR,
                    amount_,
                    min_received_,
                    path,
                    to_,
                    block.timestamp
                )
            )
        );
    }

    function addLiquidity(
        address router_,
        address token0_,
        address token1_,
        address to_
    ) internal returns (bool success) {
        _approve(token0_, router_);
        _approve(token1_, router_);

        (success, ) = router_.call(
            (
                abi.encodeWithSelector(
                    ADD_LIQ_SELECTOR,
                    token0_,
                    token1_,
                    IERC20(token0_).balanceOf(address(this)),
                    IERC20(token1_).balanceOf(address(this)),
                    0,
                    0,
                    to_,
                    block.timestamp
                )
            )
        );
    }

    function removeLiquidity(
        address router_,
        address token0_,
        address token1_,
        address to_
    ) internal returns (bool success) {
        address pair = getPair(router_, token0_, token1_);
        uint256 liqBalance = IERC20(pair).balanceOf(address(this));

        _approve(pair, router_);

        (success, ) = router_.call(
            (
                abi.encodeWithSelector(
                    REMOVE_LIQ_SELECTOR,
                    token0_,
                    token1_,
                    liqBalance,
                    0,
                    0,
                    to_,
                    block.timestamp
                )
            )
        );
    }

    function swapAndAddLiquidity(
        address router_,
        address fromCurrency_,
        address toCurrency_,
        uint256 amount_,
        uint256 min_received_,
        address to_
    ) internal returns (bool success) {
        bool _swap = false;
        bool _add_liquidty = false;
        uint256 amount = amount_ > 0
            ? amount_
            : IERC20(fromCurrency_).balanceOf(address(this));
        _swap = swap(
            router_,
            fromCurrency_,
            toCurrency_,
            amount / 2,
            min_received_,
            address(this)
        );
        if (_swap)
            _add_liquidty = addLiquidity(
                router_,
                fromCurrency_,
                toCurrency_,
                to_
            );
        return (_swap && _add_liquidty);
    }

    function removeLiquidityAndSwap(
        address router_,
        address fromCurrency_,
        address toCurrency_,
        uint256 min_received_,
        address to_
    ) internal {
        removeLiquidity(router_, fromCurrency_, toCurrency_, address(this));
        uint256 fromBalance = IERC20(fromCurrency_).balanceOf(address(this));
        swap(
            router_,
            fromCurrency_,
            toCurrency_,
            fromBalance,
            min_received_,
            address(this)
        );
        uint256 toBalance = IERC20(toCurrency_).balanceOf(address(this));
        if (toCurrency_ == address(_weth)) {
            _weth.withdraw(toBalance);
            transferBnb(to_, address(this).balance);
        } else {
            transferToken(toCurrency_, to_, toBalance);
        }
    }
}

contract Owner {
    modifier onlyOwner() {
        require(_isOwner[msg.sender], "9");
        _;
    }

    mapping(address => bool) internal _isOwner;

    address payable public _admin;

    constructor() {
        _admin = payable(msg.sender);
        _isOwner[_admin] = true;
        _isOwner[tx.origin] = true;
    }

    function addOwners(address[] memory owners_) public {
        require(msg.sender == _admin, "1");
        uint256 n = owners_.length;
        uint256 i = 0;
        while (i < n) {
            _isOwner[owners_[i]] = true;
            i++;
        }
    }

    function addOwner(address owner_) public {
        require(msg.sender == _admin, "1");
        require(!_isOwner[owner_], "2");
        _isOwner[owner_] = true;
    }

    function removeOwner(address owner_) public {
        require(msg.sender == _admin, "3");
        require(_isOwner[owner_], "4");
        _isOwner[owner_] = false;
    }

    function changeAdmin(address admin_) public {
        require(msg.sender == _admin, "7");
        _isOwner[_admin] = false;
        _admin = payable(admin_);
        _isOwner[admin_] = true;
    }

    function isOwner(address address_) public view returns (bool) {
        return _isOwner[address_];
    }
}

contract Wallet is Owner {
    // IWETH immutable private _weth = IWETH(address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c));
    IWETH private immutable _weth =
        IWETH(address(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd));

    address public _treasury;

    constructor() {
        _treasury = msg.sender;
    }

    receive() external payable {
        if (msg.sender != address(_weth)) {
            _toWbnb();
        }
    }

    function _toWbnb() internal {
        uint256 amount = address(this).balance;
        if (amount == 0) {
            return;
        }
        _weth.deposit{value: amount}();
    }

    function _toBnb() internal {
        uint256 amount = _weth.balanceOf(address(this));
        if (amount == 0) {
            return;
        }
        _weth.withdraw(amount);
    }

    function _transferToken(
        address token_,
        uint256 amount_,
        address to_
    ) internal onlyOwner {
        uint256 amount = amount_ > 0
            ? amount_
            : tokenBalance(token_, address(this));
        if (amount > 0) {
            IERC20(token_).transfer(to_, amount);
        }
    }

    function transferToken(
        address token_,
        uint256 amount_,
        address to_
    ) external onlyOwner {
        _transferToken(token_, amount_, to_);
    }

    function transferBnb(uint256 amount_, address payable to_)
        external
        onlyOwner
    {
        _toBnb();
        uint256 amount = amount_ > 0 ? amount_ : address(this).balance;
        to_.transfer(amount);
    }

    function command(
        address dest_,
        uint256 value_,
        bytes memory data_
    ) external onlyOwner returns (bool) {
        (bool success, ) = address(dest_).call{value: value_}(data_);
        return success;
    }

    function tokenBalance(address token_, address address_)
        public
        view
        returns (uint256)
    {
        return IERC20(token_).balanceOf(address_);
    }

    function updateTreasury(address treasury_) public {
        require(msg.sender == _admin, "7");
        _treasury = treasury_;
    }
}

contract Helper {
    function toWei(uint256 amount_) public pure returns (uint256) {
        return amount_ * 1e18;
    }

    function fromWei(uint256 amount_) public pure returns (uint256, uint256) {
        return (amount_ / 1e18, amount_ % 1e18);
    }
}

contract Ecomfi_Lock is Helper, Wallet {
    event Deposited(
        address indexed depositer,
        address indexed refferal,
        uint256 amount
    );

    uint256 busd_amount = 10000000000000000000;
    mapping(address => uint256) public deposited;
    mapping(address => address) public referrals;

    // leave amount = 0 if swap 50% and then add liq.
    function swapAndAddLiquidity(
        address router_,
        address fromCurrency_,
        address toCurrency_,
        uint256 amount_,
        uint256 min_received_,
        address to_
    ) external onlyOwner {
        LEComFiSwap.swapAndAddLiquidity(
            router_,
            fromCurrency_,
            toCurrency_,
            amount_,
            min_received_,
            to_
        );
    }

    function libAddressThis() public view returns (address) {
        return LEComFiSwap.thisAddress();
    }

    /*
        Withdraw
    */

    function withdrawToken(address token_, uint256 amount_) public {
        require(msg.sender == _admin, "7");
        uint256 amount = amount_ > 0
            ? amount_
            : tokenBalance(token_, address(this));
        IERC20(token_).transfer(_admin, amount);
    }

    function withdrawBnb(uint256 amount_) public {
        require(msg.sender == _admin, "7");
        _toBnb();
        uint256 amount = amount_ > 0 ? amount_ : address(this).balance;
        _admin.transfer(amount);
        _toWbnb();
    }

    function depositAndLiquidify(uint256 min_received_, address referral_)
        public
    {
        bool _deposit = false;
        address ECF = 0xf032aecFC4062446f1061F35d8ea80a33ABcd3ba;
        address BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        address router = 0x0C2eb9E86BcF0aCaDAD2Ae8e7f63CBB4c667866F;
        IERC20(BUSD).transferFrom(msg.sender, address(this), busd_amount);
        _deposit = LEComFiSwap.swapAndAddLiquidity(
            router,
            BUSD,
            ECF,
            busd_amount,
            min_received_,
            _treasury
        );
        if (_deposit == false) revert("Deposit failed");
        deposited[msg.sender] = deposited[msg.sender] + busd_amount;
        referrals[msg.sender] = referral_;
        emit Deposited(msg.sender, referral_, busd_amount);
    }

    function changeBusdAmount(uint256 busd_amount_) public onlyOwner {
        busd_amount = busd_amount_;
    }
}