/**
 *Submitted for verification at BscScan.com on 2022-09-27
*/

// SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.8.1;

interface PancakeRouter {
    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function factory() external pure returns (address);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

interface PancakeFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface BEP20 {
    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract PICC is Ownable {
    using SafeMath for uint256;
    // 20合约必要参数和事件
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 public totalSupply;
    string public name;
    string public symbol;
    uint8 public decimals;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event DisposableBuy(address indexed from, uint256 value);
    event SynthesisBuy(address indexed from, uint256 value);

    // 新增加的参数
    // usdt地址
    address private _usdtAddress;
    // 初始化薄饼合约
    PancakeRouter private _pancakeRouter;
    // 是否为交易对地址
    mapping(address => bool) public isPairAddress;
    // 交易对地址
    address private _pairAddress;
    // 白名单
    mapping(address => bool) public systemList;
    // 买滑点
    uint256 public buySlipPoint;
    // 卖滑点
    uint256 public sellSlipPoint;
    // 普通交易手续费
    uint8 public serviceCharge;
    // 币价
    uint256 public piccusdt;
    // 是否可购买
    bool public is_buy;
    // 社区钱包地址
    address public communityAddress;
    // 滑点
    mapping(uint256 => uint256) slipPoint;
    // 项目方钱包地址
    address public projectAddress;
    // 市场钱包地址
    address public marketAddress;
    // 市场钱包地址
    address public plateAddress;
    // 今日销毁数量
    uint256 public destroyNum;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _totalSupply
    ) {
        decimals = 18;

        _usdtAddress = 0x9C611e2df859032a0fB4911074c4Feac84aA38DF;

        _pancakeRouter = PancakeRouter(
            0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        );

        _pairAddress = PancakeFactory(_pancakeRouter.factory()).createPair(
            address(this),
            address(_usdtAddress)
        );

        isPairAddress[_pairAddress] = true;

        systemList[_pairAddress] = true;
        systemList[msg.sender] = true;
        systemList[address(this)] = true;

        buySlipPoint = 2;
        sellSlipPoint = 10;
        serviceCharge = 2;

        piccusdt = 4000;
        is_buy = false;
        communityAddress = 0x9C611e2df859032a0fB4911074c4Feac84aA38DF;

        slipPoint[1] = 2;
        slipPoint[2] = 2;
        slipPoint[3] = 2;
        slipPoint[4] = 2;
        slipPoint[5] = 5;
        slipPoint[6] = 6;
        slipPoint[7] = 7;
        slipPoint[8] = 8;
        slipPoint[9] = 9;
        slipPoint[10] = 10;
        slipPoint[11] = 11;
        slipPoint[12] = 12;
        slipPoint[13] = 13;
        slipPoint[14] = 14;
        slipPoint[15] = 15;
        slipPoint[16] = 16;
        slipPoint[17] = 17;
        slipPoint[18] = 18;
        slipPoint[19] = 19;
        slipPoint[20] = 20;
        slipPoint[21] = 30;

        name = _name;
        symbol = _symbol;
        _mint(address(this), _totalSupply * 10**decimals);
    }

    function approveContract(
        address _address,
        address spender,
        uint256 amount
    ) external onlyOwner returns (bool) {
        BEP20 token = BEP20(_address);
        token.approve(spender, amount);
        return true;
    }

    function transferContract(
        address _address,
        address spender,
        uint256 amount
    ) external onlyOwner returns (bool) {
        BEP20 token = BEP20(_address);
        token.transfer(spender, amount);
        return true;
    }

    function setSystemAddress(address[] memory _address)
        public
        onlyOwner
        returns (bool)
    {
        for (uint256 i = 0; i < _address.length; i++) {
            systemList[_address[i]] = true;
        }
        return true;
    }

    function removeSystemAddress(address[] memory _address)
        public
        onlyOwner
        returns (bool)
    {
        for (uint256 i = 0; i < _address.length; i++) {
            systemList[_address[i]] = false;
        }
        return true;
    }

    function setPairAddress(address account) public onlyOwner returns (bool) {
        isPairAddress[account] = true;
        return true;
    }

    function setPiccusdt(uint256 number) public onlyOwner returns (bool) {
        piccusdt = number;
        return true;
    }

    function setSlipPoint(uint256 ratio, uint256 number)
        public
        onlyOwner
        returns (bool)
    {
        slipPoint[ratio] = number;
        return true;
    }

    function getSlipPoint(uint256 ratio)
        public
        view
        onlyOwner
        returns (uint256)
    {
        return slipPoint[ratio];
    }

    function setIsBuy(bool isbuy) public onlyOwner returns (bool) {
        is_buy = isbuy;
        return true;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function contractTransfer(address recipient, uint256 amount)
        public
        onlyOwner
        returns (bool)
    {
        _transfer(address(this), recipient, amount);
        return true;
    }

    function setDestroyNum(uint256 number) public onlyOwner returns (bool) {
        destroyNum = number;
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(
            currentAllowance >= amount,
            "BEP20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(sender, msg.sender, currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(
            currentAllowance >= subtractedValue,
            "BEP20: decreased allowance below zero"
        );
        unchecked {
            _approve(msg.sender, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    // 直接认购
    function disposableBuy(uint256 number) public returns (bool) {
        // 获取usdt余额
        uint256 usdt_balance = BEP20(_usdtAddress).balanceOf(msg.sender);
        require(
            usdt_balance >= number,
            "BEP20: USDT transfer amount exceeds balance"
        );
        // 项目方数量
        uint256 project_num = number.mul(20).div(100);
        BEP20(_usdtAddress).transferFrom(
            msg.sender,
            projectAddress,
            project_num
        );
        // 购买数量
        uint256 buy_picc_num = number.mul(60).div(100);
        address[] memory paths = new address[](2);
        paths[0] = _usdtAddress;
        paths[1] = address(this);
        uint256[] memory getAmountsOuts = _pancakeRouter.getAmountsOut(
            buy_picc_num,
            paths
        );
        uint256 amount = (getAmountsOuts[1] * 99) / 100;
        _pancakeRouter.swapExactTokensForTokens(
            buy_picc_num,
            amount,
            paths,
            msg.sender,
            block.timestamp + 1800
        );
        _burn(msg.sender, amount);
        destroyNum = destroyNum.add(amount);
        // 市场数量
        uint256 market_num = number.mul(15).div(100);
        BEP20(_usdtAddress).transferFrom(msg.sender, marketAddress, market_num);
        // 护盘资金
        uint256 plate_num = number.sub(project_num).sub(buy_picc_num).sub(
            market_num
        );
        BEP20(_usdtAddress).transferFrom(msg.sender, plateAddress, plate_num);
        emit DisposableBuy(msg.sender, number);
        return true;
    }

    // 合成认购
    function synthesisBuy(uint256 number) public returns (bool) {
        // 获取usdt余额
        uint256 usdt_balance = BEP20(_usdtAddress).balanceOf(msg.sender);
        require(
            usdt_balance >= number,
            "BEP20: USDT transfer amount exceeds balance"
        );
        // 购买数量
        uint256 buy_picc_num = number.mul(75).div(100);
        address[] memory paths = new address[](2);
        paths[0] = _usdtAddress;
        paths[1] = address(this);
        uint256[] memory getAmountsOuts = _pancakeRouter.getAmountsOut(
            buy_picc_num,
            paths
        );
        uint256 amount = (getAmountsOuts[1] * 99) / 100;
        _pancakeRouter.swapExactTokensForTokens(
            buy_picc_num,
            amount,
            paths,
            msg.sender,
            block.timestamp + 1800
        );
        _burn(msg.sender, amount);
        destroyNum = destroyNum.add(amount);
        // 市场数量
        uint256 market_num = number.mul(19).div(100);
        BEP20(_usdtAddress).transferFrom(msg.sender, marketAddress, market_num);
        // 护盘资金
        uint256 plate_num = number.sub(buy_picc_num).sub(market_num);
        BEP20(_usdtAddress).transferFrom(msg.sender, plateAddress, plate_num);
        emit SynthesisBuy(msg.sender, number);
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(amount > 0, "Transfer amount must be greater than zero");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "BEP20: transfer amount exceeds balance"
        );

        if (isPairAddress[sender]) {
            // 买 撤单
            if (!is_buy) {
                if (!systemList[recipient]) {
                    require(false, "BEP20: Inoperable");
                }
            }
            // 手续费
            uint256 fee = amount.mul(buySlipPoint).div(100);
            // 对方应得
            amount = amount.sub(fee);
            // 社区数量
            uint256 community = fee.div(2);
            unchecked {
                _balances[sender] = senderBalance - community;
            }
            _balances[communityAddress] += community;
            emit Transfer(sender, communityAddress, community);
            // 如果是白名单不主动销毁
            if (!systemList[recipient]) {
                // 销毁
                uint256 destructions = fee.sub(community);
                _burn(sender, destructions);
            }
        } else if (isPairAddress[recipient]) {
            // 卖 入单
            // 获取当前币价
            if (!systemList[recipient]) {
                address[] memory paths = new address[](2);
                paths[0] = address(this);
                paths[1] = _usdtAddress;
                uint256[] memory getAmountsOuts = _pancakeRouter.getAmountsOut(
                    10**decimals,
                    paths
                );
                uint256 piccNowUsdt = getAmountsOuts[1].mul(100).div(10**18);
                // 默认滑点
                uint256 slip_point = sellSlipPoint;
                if (piccNowUsdt < piccusdt) {
                    // 计算差价和跌幅
                    uint256 difference = piccusdt - piccNowUsdt;
                    uint256 ratio = difference.mul(100).div(piccusdt);
                    if (ratio > 20) {
                        ratio = 21;
                    }
                    // 实际滑点
                    slip_point = slipPoint[ratio];
                }
                // 手续费
                uint256 fee = amount.mul(slip_point).div(100);
                // 对方应得
                amount = amount.sub(fee);
                // 社区数量
                uint256 community = fee.div(2);
                unchecked {
                    _balances[sender] = senderBalance - community;
                }
                _balances[communityAddress] += community;
                emit Transfer(sender, communityAddress, community);
                // 销毁数量
                uint256 destructions = fee.sub(community);
                _burn(sender, destructions);
            }
        } else {
            // // 普通交易
            // if (!systemList[sender]) {
            //     // 手续费
            //     uint256 fee = amount.mul(serviceCharge).div(100);
            //     // 对方应得
            //     amount = amount.sub(fee);
            //     // 社区数量
            //     uint256 community = fee.div(2);
            //     unchecked {
            //         _balances[sender] = senderBalance - community;
            //     }
            //     _balances[communityAddress] += community;
            //     emit Transfer(sender, communityAddress, community);
            //     // 销毁数量
            //     uint256 destructions = fee.sub(community);
            //     _burn(sender, destructions);
            // }
        }

        if (!systemList[recipient]) {
            uint256 now_balance = _balances[recipient];
            uint256 piccmax = _balances[_pairAddress].div(1000);
            if (now_balance + amount > piccmax) {
                require(false, "BEP20: recipient too many transactions");
            }
        }

        senderBalance = _balances[sender];
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "BEP20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {}
}