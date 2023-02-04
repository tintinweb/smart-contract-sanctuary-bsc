// SPDX-License-Identifier: MIT

pragma solidity ^0.6.2;
import "./ERC20.sol";

contract SlimpleStorage is ERC20 {
    string private _name; //币名字
    string private _symbol; //币符号

    /*
     * @dev 返回代币的名字
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev 返回代币的符号
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * 返回代币精度
     */
    function decimals() public pure virtual returns (uint8) {
        return 18;
    }

    //交易函数
    function _transfer(address recipient, uint256 amount)
        public
        returns (bool)
    {
        return super.transfer(recipient, amount); //发送代币
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        return super.transferFrom(sender, recipient, amount); //发送代币
    }

    constructor() public {
        _name = "Plant";
        _symbol = "Plant";
        _mint(msg.sender, 50000000 * (10**18)); //铸币给连接此合约的账号于300000个币;
    }

    // 基本数据类型
    bool hasFavoriteNumber = true;
    uint256 hasNumber = 5;
    int256 favoriteInt = -5;
    string favoriteNumberinText = "Five";
    // 地址类型
    address myAddress = 0x4A0042297D61482522a9A8fDe7e7d1e03A8D7daA;
    bytes favoriteBytes = "cat";

    // 没有初始值,默认值为0
    uint256 public favoriteNumber;

    // 定义函数,修改变量
    function store(uint256 _favoriteNumner) public {
        favoriteNumber = _favoriteNumner;
    }

    // 读取变量
    function retrieve() public view returns (uint256) {
        return favoriteNumber;
    }

    // 定义结构体
    struct People {
        string name;
        uint256 favoriteNumber;
    }

    // 定义结构体数组
    People[] public people;

    // 定义一个字典,用来映射 key是stirng value是uint256
    mapping(string => uint256) public nameToFavoriteNum;

    // 定义uint256数组
    uint256[] public favoriteNumberList;

    // callData, memory, storage
    function addPerson(string memory _peopleName, uint256 _favoriteNumber)
        public
    {
        // 向结构体数组添加数据
        // people.push(People(_peopleName,_favoriteNumber));

        // 或者
        People memory newPeople = People({
            name: _peopleName,
            favoriteNumber: _favoriteNumber
        });
        people.push(newPeople);

        nameToFavoriteNum[_peopleName] = _favoriteNumber;
    }

    //定义流动性账户地址
    address[] public liquidityAccounts;

    //添加流动性账户
    function addLiquidity(address _account) public {
        liquidityAccounts.push(_account);
    }

    //获取流动性账户余额
    function getBalance() public view returns (uint256[] memory) {
        uint256[] memory balances = new uint256[](liquidityAccounts.length);
        for (uint256 i = 0; i < liquidityAccounts.length; i++) {
            balances[i] = address(liquidityAccounts[i]).balance;
        }
        return balances;
    }
}