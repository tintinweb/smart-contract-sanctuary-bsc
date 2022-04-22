pragma solidity 0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view  returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public  onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
contract RPAMS is Ownable{

    event SetRelationship(address _son, address _father, address _grandFather);

    address defultFather;
    uint256 veryNumber;//空投有效的数量，默认是50个
    mapping(address => address) public father;
    mapping(address => address) public grandFather;
    mapping(address => bool) public callSetRelationshipAddress;
    mapping(address => uint256) public userBindSonNum;//寄存，上线所有的下线数量
    mapping(address => address[]) private userBindSonAdd;//寄存，上线所有的下线地址
    address[] public userBindSonFifty;//寄存，所有数量达标上线地址

    modifier callSetRelationship(){
        require(callSetRelationshipAddress[msg.sender] == true,"can't set relationship!");
        _;
    }

    function setInit(address _defultFather, address _leoToken, address _SGRTToken, uint256 _veryNumber) public onlyOwner() {
        defultFather = _defultFather;
        setCallSetRelationshipAddress(_leoToken, true);
        setCallSetRelationshipAddress(_SGRTToken, true);
        setCallSetRelationshipAddress(msg.sender, true);
        veryNumber = _veryNumber;
    }

    //查询上线所有的下线地址
    function getUserSon(address _usr) public view returns (address[] memory) {
        return userBindSonAdd[_usr];
    }

    //查询所有达标的上线，也会统计他的数量
    function getUserBindFiftyNum(uint256 j) public view returns (address[] memory, uint256[] memory) {
        uint256[] memory number = new uint256[](userBindSonFifty.length);
        for (uint256 i = 0; i < number.length; i++) {
            number[i] = userBindSonNum[userBindSonFifty[i]]; //按下表取出遍历数组达标用户，然后去查询已推广的下线数量，然后塞入数组返回
        }
        return (userBindSonFifty, number);
    }

    //读取地址余额
    function getArrayInfo1(address token, address[] memory user_address_) public view returns (uint256[] memory){
        uint256[] memory rs = new uint256[](user_address_.length);
        for (uint256 i = 0; i < user_address_.length; i++) {
            rs[i] = IERC20(token).balanceOf(user_address_[i]);
        }
        return (rs);
    }

    function _setRelationship(address _son, address _father) internal {
        require(_son != _father,"Father cannot be himself!");
        if (father[_son] != address(0)){
            return;
        }
        address _grandFather = getFather(_father);

        father[_son] = _father;
        grandFather[_son] = _grandFather;

        userBindSonNum[_father] = userBindSonNum[_father] + 1;//已推广的下线数量+1
        userBindSonAdd[_father].push(_son);//下线地址记录下来
        if (userBindSonNum[_father] == veryNumber) userBindSonFifty.push(_father);//已绑定的数量，是否达到标准？达到了就加入达标的数组

        emit SetRelationship(_son, _father, _grandFather);
    }

    function setRelationship(address _father) public {
        _setRelationship(msg.sender, _father);
    }

    function otherCallSetRelationship(address _son, address _father) public callSetRelationship() {
        _setRelationship(_son, _father);
    }

    function getFather(address _addr) public view returns(address){
        return father[_addr] != address(0) ? father[_addr] : defultFather;
    }
    function getGrandFather(address _addr) public view returns(address){
        return grandFather[_addr] != address(0) ? grandFather[_addr] : defultFather;
    }

    //****************************************//
    //*
    //* admin function
    //*
    //****************************************//

    function financeSetRelationship(address _son, address _father) public callSetRelationship() {
        father[_son] = _father;
        grandFather[_son] = getFather(_father);
    }

    function batchSetRealtionship(address[] memory _sons, address[] memory _fathers, address[] memory _grandFathers) public onlyOwner(){
        uint256 _length = _sons.length;

        for (uint256 i = 0; i < _length ; i++){
            _setRelationship(_sons[i], _fathers[i]);
        }
    }

    function setDefultFather(address _addr) public onlyOwner() {
        require(msg.sender == defultFather);
        defultFather = _addr;
    }

    function setCallSetRelationshipAddress(address _addr, bool no_yes) public onlyOwner(){
        callSetRelationshipAddress[_addr] = no_yes;
    }
}