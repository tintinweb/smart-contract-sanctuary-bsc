/**
    可升级业务逻辑合约程序。需要满足OpenZeppelin可升级合约的条件,包含继承引用的父合约。
注意事项:
可升级合约的存储不能乱，即：只能新增存储项，不能修改顺序
没有构造函数，使用initialize替代
继承的父合约也需要能满足升级，本例中的Ownable采用OwnableUpgradeable，支持升级
可使用OpenZeppelin插件验证合约是否为可升级合约，以及升级时是否有冲突。

部署后，先不进行初始化（initialize，本方法对应的code为 0x8129fc1c ）后面通过部署代理合约来进行初始化。

测试网：
第一次部署： 0xE7976D53B32648cFE9Ef6CB3e8Cd81af4804cf9E  已开源
执行 SetUint256Param： abc,1 
修改合约，添加一个方法
第二次部署： 

 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./All_Upgradeable.sol";

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract AS_Token is ERC20Upgradeable,OwnableUpgradeable {
    using AddressUpgradeable for address; //使用

    //自定义结构体
    struct Map {
        address[] keys;  //地址
        mapping(address => uint256) values; //地址值
        mapping(address => uint256) indexOf;//索引值
        mapping(address => bool) inserted;  //已插入
    }

    Map private tokenHoldersMap;            //代币持有者地图    
        
    string private constant _name = "AS Token";
    string private constant _symbol = "AS";   
    uint8  private  _decimals;
    uint256 private _totalSupply;           //总供应量

    //__________________ upgrade 升级

    //bool public contractStatus = true;  //upgrade add 合约正常才能转

	function initialize()public initializer{
        __ERC20_init_unchained("AS Token", "AS");  //代币的名称、符号
        __Context_init_unchained();
        __Ownable_init_unchained();
        _mint(msg.sender, 1000000 ether);   //产币10万给合约提交者
	}
    
    //获取地址总数
    function size() public view returns (uint256) {
        return tokenHoldersMap.keys.length;
    }
    //获取币的数量 代币持有者地图.values
    function balanceOf(address addr) public view override returns (uint){
        return tokenHoldersMap.values[addr];
    }
    //总供应量
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    //铸币
    function _mint(address account, uint256 amount) internal override {
        require(account != address(0), "ERC20: mint to the zero address");
        //在任何令牌转移之前调用的钩子。这包括铸造和燃烧。
        _beforeTokenTransfer(address(0), account, amount); //初始化
        uint balance = tokenHoldersMap.values[account];
        _totalSupply += amount;
        set(account, balance + amount);
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
    }
    
    //================ 地址结构体集合相关操作 ================

    // 通过地址获取 地址的值 （与 balanceOf 功能一样）可以不用
    function get(address key) public view returns (uint256) {
        return tokenHoldersMap.values[key];
    }
    //通过地址 获取 索引位置 
    function getIndexOfKey(address key) public view returns (int256)  {
        if (!tokenHoldersMap.inserted[key]) {
            return - 1;
        }
        return int256(tokenHoldersMap.indexOf[key]);
    }
    //通过索引，获取地址
    function getKeyAtIndex(uint256 index) public view returns (address)  {
        return tokenHoldersMap.keys[index];
    }
    //持币地址图 添加 或 修改值
    function set(address key,uint256 val) private {
        if (tokenHoldersMap.inserted[key]) { //地址已存在，则赋值
            tokenHoldersMap.values[key] = val;
        } else { //新地址
            tokenHoldersMap.inserted[key] = true; //设置此地址有了
            tokenHoldersMap.values[key] = val; //赋值
            tokenHoldersMap.indexOf[key] = tokenHoldersMap.keys.length; //设置索引位置
            tokenHoldersMap.keys.push(key); //压入集合
        }
    }
    //从地址图里 移除地址
    function remove(address key) private {
        if (!tokenHoldersMap.inserted[key]) {  //地址不存在
            return; 
        }

        delete tokenHoldersMap.inserted[key]; //删除插入状态
        delete tokenHoldersMap.values[key];   //删除值记录

        uint256 index = tokenHoldersMap.indexOf[key];         //获取索引位置
        uint256 lastIndex = tokenHoldersMap.keys.length - 1;  //获取最后一个索引值
        address lastKey = tokenHoldersMap.keys[lastIndex];    //获取最后一个索引的地址

        tokenHoldersMap.indexOf[lastKey] = index;   //最后一个地址的索引，换为移除地址的索引
        delete tokenHoldersMap.indexOf[key];   //删除此地址的索引

        tokenHoldersMap.keys[index] = lastKey; //该索引位置，设置为最后这个地址

        tokenHoldersMap.keys.pop();  //弹出地图最后一个
    }


    function _transfer(address sender,address recipient,uint256 amount) internal override {
        require(sender != address(0), "ERC20: transfer from the zero address");     //发送地址不是0
        require(balanceOf(sender) >= amount, "ERC20: transfer amount exceeds balance"); //发送者余额不足
        set(sender, balanceOf(sender) - amount);
        set(recipient, balanceOf(recipient) + amount);
        //如果币为0则从地址图里移除
        if (balanceOf(sender) == 0) { 
            remove(sender); 
        }
        emit Transfer(sender, recipient, amount);
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    //两地址转账 (多用于交易)
    function transferFrom(address sender,address recipient,uint256 amount) public virtual override returns (bool) {
        //require(!contractStatus, 'contract lock');  //upgrade add 合约正常才能转

        _transfer(sender, recipient, amount);

        //确保有授权才执行
        uint256 currentAllowance = allowance(sender, _msgSender());
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }
}