/**
 *Submitted for verification at BscScan.com on 2022-04-21
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-19
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address public _owner;

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
   
    function renounceOwnership() public  onlyOwner {
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public  onlyOwner {
        require(newOwner != address(0),"Ownable: new owner is thezeroAddress address");
        _owner = newOwner;
    }
}

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not beingzeroAddress, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface IERC20 {
    struct Relation{
        address one;
        address two;
        address three;
        address four;
        address five;
        address six;
        address seven;
        address eight;
        address nine;
        address ten;
    }
    function getRelation(address account) external view returns(Relation memory);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract VirtualMachineToken is Ownable {
    using SafeMath for uint256;

    uint256 private _daySecond = 86400;
    uint256 private date = 200;
    uint256 private fee1Rate;
    uint256 private fee2Rate;
    uint256 private _decimals;

    address public dct;
    address public usdt;
    address private zeroAddress = address(0);
    address public collectAddress = 0x2618E49B8c049053120659690A33895feA44c49f; // ???U??????

    bool public stopBuy;

    mapping (uint256 => VirtualMachine) private _virtualMachineMap;
    mapping (address => Order[]) private orders;
    mapping (address => uint256) private _recommReward;
    mapping (uint256 => uint256) private _recordDeposite;

    // ??????
    struct Order {
        uint256 option; // 1 ??????1????????????   4?????????????????????
        uint256 startime;
        uint256 endtime;
        uint256 lastime; // ??????????????????
        uint256 cycle; // ????????????
        uint256 amount; // ???????????????
        uint256 unReleaseAmount; // ???????????????
        uint256 releaseAmount; // ???????????????
    }

    // ?????????
    struct VirtualMachine {
        uint256 price; // ??????
        uint256 cycle; // ??????
        uint256 parameter; // ??????
        uint256 amount; // ????????????
    }


    event BuyVirtualMachine(address indexed sender, uint256 amount);
    event WithdrawLinearRelease(address indexed sender, uint256 amount);
    
    constructor(address _dct, address _usdt) {
        _owner = msg.sender;
        dct = _dct;
        usdt = _usdt;
        _decimals = 18;
        // ??????????????????
        _virtualMachineMap[1] = VirtualMachine(100*10**_decimals, 200, 150*10**_decimals, 6506);
        _virtualMachineMap[2] = VirtualMachine(2000*10**_decimals, 200, 4000*10**_decimals, 8000);
        _virtualMachineMap[3] = VirtualMachine(5000*10**_decimals, 200, 15000*10**_decimals, 3000);
        _virtualMachineMap[4] = VirtualMachine(10000*10**_decimals, 300, 40000*10**_decimals, 108);
        fee1Rate = 60; // 1-3???????????????
        fee2Rate = 30; // 4-10????????????
    }

    // ??????????????????????????????
    function getVirtualMachineAmount(uint256 option) public view returns(uint256){
        return _virtualMachineMap[option].amount;
    }

    // ??????????????????????????????
    function getVirtualDepositeAmount(uint256 option) external view returns(uint256){
        return _recordDeposite[option];
    }

    // ?????????????????????????????????DCT??????
    function getUserReleaseAndNo(address sender) external view returns(uint256 release, uint256 unRelease){
        for (uint i = 0; i < orders[sender].length; i++) {
            release = release.add(orders[sender][i].releaseAmount);
            unRelease = unRelease.add(orders[sender][i].unReleaseAmount);
        }
    }

    // ?????????????????????????????????DCT??????
    function getCanWithdrawAmount(address sender) external view returns(uint256 totalAmount){
        for (uint i = 0; i < orders[sender].length; i++) {
            if (orders[sender][i].unReleaseAmount <= 0) {
                continue;
            }

            if (block.timestamp < orders[sender][i].lastime) {
                continue;
            }

            uint256 _date = block.timestamp;
            
            if (block.timestamp > orders[sender][i].endtime){
                _date = orders[sender][i].endtime;
            }

            uint256 interval = _date - orders[sender][i].lastime;

            uint256 withdrawAmount = orders[sender][i].amount.mul(interval).div(orders[sender][i].cycle * _daySecond);
            if (withdrawAmount <= 0) {
                continue;
            }

            if (orders[sender][i].unReleaseAmount < withdrawAmount){
                withdrawAmount = orders[sender][i].unReleaseAmount;
            }
            totalAmount = totalAmount.add(withdrawAmount);
        }
        uint256 balance = _recommReward[sender];
        totalAmount = totalAmount.add(balance);
    }

    function getRelation() external view returns(IERC20.Relation memory){
        address sender = msg.sender;
        IERC20.Relation memory relation = IERC20(dct).getRelation(sender);
        return relation;
    }


    // ??????????????????1-4???
    function buyVirtualMachine(uint256 option) external {
        // ??????????????????
        address sender = msg.sender;
        IERC20.Relation memory relation = IERC20(dct).getRelation(sender);

        require(!stopBuy, "NO_OPEN"); // ?????????????????????
        require(getVirtualMachineAmount(option) > 0, "SELL_OUT"); // ?????????????????????0????????????

        uint256 approveAmount = IERC20(usdt).allowance(sender, address(this)); // ?????????????????????USDT?????????????????????

        require(approveAmount >= _virtualMachineMap[option].price, "INSUFFICIENT_FUNDS");

        IERC20(usdt).transferFrom(sender, collectAddress, _virtualMachineMap[option].price);

        // ??????????????????????????????
        _recordDeposite[option] = _recordDeposite[option].add(_virtualMachineMap[option].price);

        // ?????????????????????
        _virtualMachineMap[option].amount = _virtualMachineMap[option].amount.sub(1);

        // ?????????????????????
        relationTransfer(relation, _virtualMachineMap[option].parameter);

        orders[sender].push(Order(option, block.timestamp, block.timestamp+date*_daySecond, block.timestamp, _virtualMachineMap[option].cycle, _virtualMachineMap[option].parameter, _virtualMachineMap[option].parameter, 0));
        emit BuyVirtualMachine(sender, _virtualMachineMap[option].price);
    }


    // ?????????????????????
    function relationTransfer(IERC20.Relation memory relation, uint256 amount) internal {
        uint256 reward1 = amount.mul(fee1Rate).div(1000);
        uint256 reward2 = amount.mul(fee2Rate).div(1000);

        if (relation.one != zeroAddress){
            _releaseAmount(relation.one, reward1);
        }

        if (relation.two != zeroAddress){
            _releaseAmount(relation.two, reward1);
        }

        if (relation.three != zeroAddress){
            _releaseAmount(relation.three, reward1);
        }

        if (relation.four != zeroAddress){
            _releaseAmount(relation.four, reward2);
        }

        if (relation.five != zeroAddress){
            _releaseAmount(relation.five, reward2);
        }

        if (relation.six != zeroAddress){
            _releaseAmount(relation.six, reward2);
        }

        if (relation.seven != zeroAddress){
            _releaseAmount(relation.seven, reward2);
        }

        if (relation.eight != zeroAddress){
            _releaseAmount(relation.eight, reward2);
        }

        if (relation.nine != zeroAddress){
            _releaseAmount(relation.nine, reward2);
        }

        if (relation.ten != zeroAddress){
            _releaseAmount(relation.ten, reward2);
        }
    }

    // ???????????????
    function withdrawLinearRelease() external {
        address sender = msg.sender;
        uint256 totalAmount;
        for (uint i = 0; i < orders[sender].length; i++) {
            if (orders[sender][i].unReleaseAmount <= 0) {
                continue;
            }

            if (block.timestamp < orders[sender][i].lastime) {
                continue;
            }

            uint256 _date = block.timestamp;
            
            if (block.timestamp >= orders[sender][i].endtime){
                _date = orders[sender][i].endtime;
            }

            uint256 interval = _date - orders[sender][i].lastime;

            uint256 withdrawAmount = orders[sender][i].amount.mul(interval).div(orders[sender][i].cycle * _daySecond);
            if (withdrawAmount <= 0) {
                continue;
            }

            if (orders[sender][i].unReleaseAmount < withdrawAmount){
                withdrawAmount = orders[sender][i].unReleaseAmount;
            }
            orders[sender][i].unReleaseAmount = orders[sender][i].unReleaseAmount.sub(withdrawAmount);
            orders[sender][i].releaseAmount = orders[sender][i].releaseAmount.add(withdrawAmount);
            
            totalAmount = totalAmount.add(withdrawAmount);
            orders[sender][i].lastime = block.timestamp;
        }
        uint256 balance = _recommReward[sender];
        totalAmount = totalAmount.add(balance);
        if (balance > 0){
            _recommReward[sender] = 0;
        }
        require(totalAmount > 0, "No tokens available");
        IERC20(dct).transfer(sender, totalAmount);
        emit WithdrawLinearRelease(sender, totalAmount);
    }

    // ????????????
    function _releaseAmount(address sender, uint256 amount) internal {
        for (uint i = 0; i < orders[sender].length; i++) {
            if (orders[sender][i].unReleaseAmount <= 0) {
                continue;
            }
            if (orders[sender][i].unReleaseAmount >= amount){
                _recommReward[sender] = _recommReward[sender].add(amount);
                orders[sender][i].unReleaseAmount = orders[sender][i].unReleaseAmount.sub(amount);
                orders[sender][i].releaseAmount = orders[sender][i].releaseAmount.add(amount);
                break;
            } else if (orders[sender][i].unReleaseAmount < amount) {
                _recommReward[sender] = _recommReward[sender].add(orders[sender][i].unReleaseAmount);
                amount = amount.sub(orders[sender][i].unReleaseAmount);
                orders[sender][i].releaseAmount = orders[sender][i].releaseAmount.add(orders[sender][i].unReleaseAmount);
                orders[sender][i].unReleaseAmount = 0;
                orders[sender][i].lastime = orders[sender][i].endtime;
            }
        }
    }

    // ??????1-3??????4-10????????? (???????????????1000)
    function setFeeRate(uint256 fee1Rate_, uint256 fee2Rate_) external onlyOwner {
        fee1Rate = fee1Rate_;
        fee2Rate = fee2Rate_;
    }

    // ???????????????????????????
    function setStopBuy() external onlyOwner {
        stopBuy = true;
    }

    // ???????????????????????????
    function setStartBuy() external onlyOwner {
        stopBuy = false;
    }

    // ?????????????????????
    function addVirtualMachineAmount(uint256 option, uint256 addAmount) external onlyOwner {
        _virtualMachineMap[option].amount = _virtualMachineMap[option].amount.add(addAmount);
    }

    // ?????????????????????
    function subVirtualMachineAmount(uint256 option, uint256 subAmount) external onlyOwner {
        _virtualMachineMap[option].amount = _virtualMachineMap[option].amount.sub(subAmount);
    }

    // ?????????????????????
    function setVirtualMachineParameter(uint256 option, uint256 parameter) external onlyOwner {
        _virtualMachineMap[option].parameter = parameter;
    }
    
    // ??????????????????
    function setVirtualMachinePrice(uint256 option, uint256 price) external onlyOwner {
        _virtualMachineMap[option].price = price;
    }

    // ????????????????????????????????????????????????????????????????????????
    function setVirtualMachineCycle(uint256 option, uint256 cycle) external onlyOwner {
        _virtualMachineMap[option].cycle = cycle;
    }

    // ????????????????????????dct
    function withdrawDCT() external onlyOwner {
        IERC20(dct).transfer(msg.sender, IERC20(dct).balanceOf(address(this)));
    }
}