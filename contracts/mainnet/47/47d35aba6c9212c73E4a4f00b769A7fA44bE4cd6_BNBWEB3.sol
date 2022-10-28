/**
 *Submitted for verification at BscScan.com on 2022-10-28
*/

pragma solidity ^0.8.0;

contract BNBWEB3 {

    struct Account {
        //用户编号
        uint256 id;
        //上级用户地址
        address parent;
        //移动下级
        bool moveFlag;
        //等级(1:AGENT; 2:Boss)
        uint level;
        //下级用户数量
        uint childrenCount;
        //[直推｜见点｜平级｜分红]
        uint256[4] balances;
        //被移动的地址
        address[2] moveAddress;
    }

    //下一个分红的编号
    uint256 private index = 3000;
    //合约拥有者钱包地址
    address private owner;
    //项目方地址
    address private projectAddress = 0xc5157E4e6e505F9ECAf91ee85e4f73B56e6E8F18;
    //手续费钱包地址
    address private feeAddress = 0xc3f37F858EfBd702a34daaAec651B8De5CC8E211;
    //全网地址
    address[] private addressArray = new address[](1);
    //id=>地址
    mapping(uint256 => address) private accounts;
    //地址=>账户信息
    mapping(address => Account) private users;
    //地址=>团队地址
    mapping(address => address[]) private team;

    constructor() {
        owner = msg.sender;
    }

    function deleteUser(address _address) public {
        require(owner == msg.sender, "User not permission");
        delete users[_address];
    }

    function addUser(address _address, Account memory _account) public {
        require(owner == msg.sender, "User not permission");
        users[_address] = _account;
    }

    function addAddress(address _address) public returns (bool){
        require(owner == msg.sender, "User not permission");
        if (containsAddress(_address)) {
            return false;
        }

        uint _size = addressArray.length;
        address[] memory _array = new address[](_size + 1);
        for (uint i; i < _size; i++) {
            _array[i] = addressArray[i];
        }
        _array[_size] = _address;
        addressArray = _array;
        return true;
    }

    function deleteAddress(address _address) public returns (bool){
        require(owner == msg.sender, "User not permission");
        if (!containsAddress(_address)) {
            return false;
        }

        uint _size = addressArray.length;

        address[] memory _array = new address[](_size - 1);
        for (uint i; i < _size; i++) {
            if (addressArray[i] == _address) {
                delete addressArray[i];
                i--;
                continue;
            }
            _array[i] = addressArray[i];
        }
        addressArray = _array;
        return true;
    }

    function deleteAccount(uint256 _id) public {
        require(owner == msg.sender, "User not permission");
        delete accounts[_id];
    }

    function addAccount(uint256 _id, address _address) public {
        require(owner == msg.sender, "User not permission");
        accounts[_id] = _address;
    }

    function deleteTeam(address _address) public {
        require(owner == msg.sender, "User not permission");
        delete team[_address];
    }

    function addTeam(address _address, address _team_account) public returns (bool){
        require(owner == msg.sender, "User not permission");
        uint _size = team[_address].length;
        address[] memory _array = new address[](_size == 0 ? 1 : _size + 1);
        if (_size > 0) {
            for (uint i; i < _size; i++) {
                if (team[_address][i] != _team_account) {
                    return false;
                }
                _array[i] = team[_address][i];
            }
        }
        _array[_size] = msg.sender;
        team[_address] = _array;
        return true;
    }

    //获取合约余额
    function balance() public view returns (uint256) {
        return address(this).balance;
    }

    function containsAddress(address _account) public view returns (bool){
        for (uint256 i; i < addressArray.length; i++) {
            if (addressArray[i] == _account) {
                return true;
            }
        }
        return false;
    }

    //向合约转账 - 注册团队
    function transfer(address _address) payable public {
        //地址判断
        require(_address != address(0), "Invalid address");
        require(_address != address(this), "Invalid address");
        require(containsAddress(_address), "Invalid address");
        //禁止合约创造者
        require(msg.sender != owner, "Invalid address");
        //禁止重复支付
        require(!containsAddress(msg.sender), "Repeat Transfer");
        //转账金额控制
        require(msg.value == 1050000000000000000, "Transfer invalid amount");


        //将用户地址加入数组
        uint _size = users[_address].childrenCount;
        address[] memory _array = new address[](_size == 0 ? 1 : _size + 1);
        if (_size > 0) {
            for (uint i; i < _size; i++) {
                _array[i] = team[_address][i];
            }
        }
        _array[_size] = msg.sender;
        team[_address] = _array;

        users[_address].childrenCount = _size + 1;

        _size = addressArray.length;
        //用户id
        uint256 _id = getNewId();
        users[msg.sender] = Account(_id, _address, false, 1, 0, [uint256(0), uint256(0), uint256(0), uint256(0)], [address(0), address(0)]);
        accounts[users[msg.sender].id] = msg.sender;
        _array = new address[](_size + 1);
        for (uint i; i < _size; i++) {
            _array[i] = addressArray[i];
        }
        _array[_size] = msg.sender;
        addressArray = _array;

        //发放奖励
        uint256 _total_rewald = rewald(_address);

        //移动团队
        move(_address);

        //项目方手续费转账
        payable(feeAddress).transfer(50000000000000000);
        //未领取的收益给到创始钱包
        payable(projectAddress).transfer(msg.value - _total_rewald - 450000000000000000);
        //2 BNB出局
        if (address(this).balance >= 2000000000000000000) {
            //计算0.95BNB
            uint256 _rewald = 95 * 10 ** 16;
            users[accounts[index]].balances[3] += _rewald;
            //分配新的用户id
            users[accounts[index]].id = _id + 1;
            accounts[_id] = accounts[index];
            delete accounts[index];

            //支付分红
            payable(accounts[_id]).transfer(_rewald);
            //项目方手续费转账
            payable(feeAddress).transfer(50000000000000000);
            //复投
            _total_rewald = rewald(users[accounts[_id]].parent);
            //未领取的收益给到创始钱包
            payable(projectAddress).transfer(msg.value - _total_rewald - 450000000000000000);
            index += 1;
        }
    }

    //是否是收益惩罚阶段
    function isPunish(address _address) private view returns (bool){
        if (users[_address].moveAddress[0] == address(0) || users[_address].moveAddress[1] == address(0)) {
            return true;
        }

        if (users[users[_address].moveAddress[0]].level != 2) {
            return true;
        }

        if (users[users[_address].moveAddress[1]].level != 2) {
            return true;
        }
        return false;
    }

    function getNewId() private view returns (uint256 id){
        for (uint256 i; i < addressArray.length; i++) {
            if (users[addressArray[i]].id > id) {
                id = users[addressArray[i]].id;
            }
        }
        return id + 1;
    }

    //奖励发放
    function rewald(address _address) private returns (uint256){
        //转账数目
        uint256 _value = 1000000000000000000;

        //直推收益(40%)
        uint256 _rewald = _value * 40 / 100;

        if (isPunish(_address)) {
            _rewald = _rewald * 90 / 100;
        }

        //用户总发放收益
        uint256 _total_rewald = _rewald;

        //收益累计 - 直推
        users[_address].balances[0] += _rewald;

        //上级见点奖励 10%
        if (users[_address].level == 2) {
            _rewald = _value * 10 / 100;
            if (isPunish(_address)) {
                _rewald = _rewald * 90 / 100;
            }
            //上级用户总收益累计
            _total_rewald += _rewald;
            //收益见点 - 直推
            users[_address].balances[1] += _rewald;
        }
        //发放上级用户收益
        payable(_address).transfer(_total_rewald);

        //上上级用户见点奖励 10%
        if (users[_address].level != 2 && users[users[_address].parent].level == 2) {
            _rewald = _value * 10 / 100;
            if (isPunish(users[_address].parent)) {
                _rewald = _rewald * 90 / 100;
            }
            payable(users[_address].parent).transfer(_rewald);
            users[users[_address].parent].balances[1] += _rewald;
            _total_rewald += _rewald;
        }

        //平级奖励(10%);

        //平级奖励 4%
        if (users[_address].level == 2 && users[users[_address].parent].level == 2) {
            _rewald = _value * 4 / 100;
            if (isPunish(users[_address].parent)) {
                _rewald = _rewald * 90 / 100;
            }
            payable(users[_address].parent).transfer(_rewald);
            users[users[_address].parent].balances[2] += _rewald;
            _total_rewald += _rewald;
        }

        if (users[_address].level == 1 && users[users[_address].parent].level == 2 && users[users[users[_address].parent].parent].level == 2) {
            _rewald = _value * 4 / 100;
            if (isPunish(users[users[_address].parent].parent)) {
                _rewald = _rewald * 90 / 100;
            }
            payable(users[users[_address].parent].parent).transfer(_rewald);
            users[users[users[_address].parent].parent].balances[2] += _rewald;
            _total_rewald += _rewald;
        }

        //平级奖励 6%
        if (users[_address].level == 2 && users[users[_address].parent].level == 2 && users[users[users[_address].parent].parent].level == 2) {
            _rewald = _value * 6 / 100;
            if (isPunish(users[users[_address].parent].parent)) {
                _rewald = _rewald * 90 / 100;
            }
            payable(users[users[_address].parent].parent).transfer(_rewald);
            users[users[users[_address].parent].parent].balances[2] += _rewald;
            _total_rewald += _rewald;
        }

        if (users[_address].level == 1 && users[users[_address].parent].level == 2 && users[users[users[_address].parent].parent].level == 2 && users[users[users[users[_address].parent].parent].parent].level == 2) {
            _rewald = _value * 4 / 100;
            if (isPunish(users[users[users[_address].parent].parent].parent)) {
                _rewald = _rewald * 90 / 100;
            }
            payable(users[users[users[_address].parent].parent].parent).transfer(_rewald);
            users[users[users[users[_address].parent].parent].parent].balances[2] += _rewald;
            _total_rewald += _rewald;
        }
        return _total_rewald;
    }

    function move(address _address) private {
        if (_address == owner) {
            return;
        }

        Account memory _parent_account = users[_address];

        if (!_parent_account.moveFlag) {
            //移动两个下级用户至上级
            uint _size = users[_parent_account.parent].childrenCount;
            uint _new_size = _size + 1;
            address[] memory _array = new address[](_new_size);
            for (uint i; i < _size; i++) {
                _array[i] = team[_parent_account.parent][i];
            }
            //移动两个下级用户
            _array[_size] = msg.sender;
            team[_parent_account.parent] = _array;

            //保存移动的地址
            for (uint i; i < 2; i++) {
                if (users[_address].moveAddress[i] == address(0)) {
                    users[_address].moveAddress[i] = msg.sender;
                    users[msg.sender].parent = _parent_account.parent;
                    break;
                }
            }

            users[_parent_account.parent].childrenCount = _new_size;

            //删除下级
            _new_size = team[_address].length - 1;
            _array = new address[](_new_size);
            for (uint i; i < _new_size; i++) {
                _array[i] = team[_address][i];
            }
            team[_address] = _array;
            //重新计算下级
            users[_address].childrenCount = _new_size;

            if (users[_address].moveAddress[0] != address(0) && users[_address].moveAddress[1] != address(0)) {
                //更新下级移动标识
                users[_address].moveFlag = true;
                //级别升级
                users[_address].level = 2;
            }
        }
    }

    function getId(address _account) public view returns (uint256){
        return users[_account].id;
    }

    function getLevel(address _account) public view returns (uint){
        return users[_account].level;
    }

    function getMoveAddress(address _account) public view returns (address[] memory _move_address){
        if (!containsAddress(_account)) {
            return _move_address;
        }

        if (users[_account].moveAddress[0] == address(0) && users[_account].moveAddress[1] == address(0)) {
            return _move_address;
        }
        uint _size = 2;
        if (users[_account].moveAddress[0] == address(0) || users[_account].moveAddress[1] == address(0)) {
            _size = 1;
        }

        _move_address = new address[](_size);

        if (users[_account].moveAddress[0] != address(0) && users[_account].moveAddress[1] != address(0)) {
            _move_address[0] = users[_account].moveAddress[0];
            _move_address[1] = users[_account].moveAddress[1];
        }

        if (users[_account].moveAddress[0] == address(0) && users[_account].moveAddress[1] != address(0)) {
            _move_address[0] = users[_account].moveAddress[1];
        }

        if (users[_account].moveAddress[0] != address(0) && users[_account].moveAddress[1] == address(0)) {
            _move_address[0] = users[_account].moveAddress[0];
        }

        return _move_address;
    }

    function getTeam(address _account) public view returns (address[] memory _accounts){
        if (!containsAddress(_account) || team[_account].length == 0) {
            return _accounts;
        }
        _accounts = new address[](team[_account].length);
        for (uint i; i < team[_account].length; i++) {
            _accounts[i] = team[_account][i];
        }
        return _accounts;
    }

    function getTeamLength(address _account) public view returns (uint){
        return users[_account].childrenCount;
    }

    //通过地址获取对应的奖励信息
    function getBalance(address _account) public view returns (uint256[] memory _balances) {
        _balances = new uint256[](4);
        for (uint i; i < users[_account].balances.length; i++) {
            _balances[i] = users[_account].balances[i];
        }
        return _balances;
    }

    //通过地址获取对应的团队业绩
    function achievement(address _address) public view returns (uint256){
        if (!containsAddress(_address)) {
            return 0;
        }
        uint256 _balance = 0;

        if (users[_address].moveAddress[0] != address(0)) {
            _balance += 1000000000000000000;
        }

        if (users[_address].moveAddress[1] != address(0)) {
            _balance += 1000000000000000000;
        }

        uint256 _size = team[_address].length;
        _balance += _size * 1000000000000000000;

        for (uint256 i; i < _size; i++) {
            _balance += achievement(team[_address][i]);
        }
        return _balance;
    }

    function getIndex() public view returns (uint256) {
        return index;
    }

    //设置权限
    function setOwner(address _address) public {
        require(owner == msg.sender, "User not permission");
        owner = _address;
    }

    //丢弃权限
    function killOwner() public {
        require(owner == msg.sender, "User not permission");
        owner = address(0);
    }

    //销毁合约
    function destroy() payable public {
        require(owner == msg.sender, "User not permission");
        payable(msg.sender).transfer(address(this).balance);
        selfdestruct(payable(msg.sender));
    }

    //设置fallback 函数，为payable属性，如果不设置这个函数，智能合约则不能接受其他合约和账户的转账
    fallback() external payable {}

    receive() external payable {}
}