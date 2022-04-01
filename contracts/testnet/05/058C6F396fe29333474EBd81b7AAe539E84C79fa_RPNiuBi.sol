pragma solidity 0.8.0;
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

contract RPNiuBi is Ownable {

    event SetRelationship(address _son, address _father, address _grandFather);

    address defultFather;
    uint256 veryNumber;
    mapping(address => address) public father;
    mapping(address => address) public grandFather;
    mapping(address => bool) public callSetRelationshipAddress;
    mapping(address => uint256) public userBindSonNum;
    mapping(address => address[]) public userBindSonAdd;
    address[] private userBindSonFifty;//所有达标上线
    address[] private userBindFa;//所有上线

    modifier callSetRelationship(){
        require(callSetRelationshipAddress[msg.sender] == true,"can't set relationship!");
        _;
    }

    function setInit(address _defultFather, address _leoToken, address _SGRTToken, uint256 _veryNumber) public onlyOwner() {
        setCallSetRelationshipAddress(msg.sender, true);
        setCallSetRelationshipAddress(_leoToken, true);
        setCallSetRelationshipAddress(_SGRTToken, true);
        veryNumber = _veryNumber;
    }

    //所有达标上线
    function getUserBindFifty(uint256 i) public view returns (address[] memory) {
        return userBindSonFifty;
    }

    //所有上线
    function getUserBindFa(uint256 i) public view returns (address[] memory) {
        return userBindFa;
    }

    //所有达标上线+数量
    function getUserBindFiftyNum(uint256 i) public view returns (address[] memory, uint256[] memory) {
        uint256[] memory number = new uint256[](userBindSonFifty.length);
        for (uint256 i = 0; i < number.length; i++) {
            number[i] = userBindSonNum[userBindSonFifty[i]];
        }
        return (userBindSonFifty, number);
    }

    function _setRelationship(address _son, address _father) internal {

        require(_son != _father,"Father cannot be himself!");
        if (father[_son] != address(0)){
            return;
        }
        address _grandFather = getFather(_father);

        father[_son] = _father;
        grandFather[_son] = _grandFather;

        if (userBindSonNum[_father] == 0) userBindFa.push(_father);//记录所有上线地址
        userBindSonNum[_father] = userBindSonNum[_father] + 1;//上线数量加1
        userBindSonAdd[_father].push(_son);//上线地址加1
        if (userBindSonNum[_father] == veryNumber) userBindSonFifty.push(_father);//记录达到标准的上线

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