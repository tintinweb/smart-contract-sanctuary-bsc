pragma solidity 0.8.0;

interface AntiInf{
    function setWhiteList(address _addr, uint256 _type, bool _YorN) external ;
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

contract RPANTI is Ownable {

    event SetRelationship(address _son, address _father, address _grandFather);

    address defultFather;
    address antiToken;

    mapping(address => address) public father;
    mapping(address => address) public grandFather;
    mapping(address => bool) public callSetRelationshipAddress;

    uint256 veryNumber;//?????????????????????????????????50???
    uint256 bmdFaChuNum;//????????????????????????1500???????????????
    mapping(address => uint256) public userBindSonNum;//????????????????????????????????????
    mapping(address => address[]) private userBindSonAdd;//????????????????????????????????????
    address[] private userBindSonFifty;//???????????????????????????????????????

    modifier callSetRelationship(){
        require(callSetRelationshipAddress[msg.sender] == true,"can't set relationship!");
        _;
    }

    function setInit(address _defultFather, address _antiToken, address _token, uint256 _veryNumber, uint256 _bmdFaChuNum) public onlyOwner() {
        setCallSetRelationshipAddress(msg.sender, true);
        setCallSetRelationshipAddress(_antiToken, true);
        antiToken = _antiToken;

        veryNumber = _veryNumber;
        bmdFaChuNum = _bmdFaChuNum;
    }

    //?????????????????????????????????
    function getUserSon(address _usr) public view returns (address[] memory) {
        return userBindSonAdd[_usr];
    }

    //?????????????????????????????????
    function getUserSonNum(address _usr) public view returns (uint256) {
        return userBindSonAdd[_usr].length;
    }

    //??????????????????????????????????????????????????????
    function getUserBindFiftyNum(uint256 j) public view returns (address[] memory, uint256[] memory) {
        uint256[] memory number = new uint256[](userBindSonFifty.length);
        for (uint256 i = 0; i < number.length; i++) {
            number[i] = userBindSonNum[userBindSonFifty[i]]; //????????????????????????????????????????????????????????????????????????????????????????????????????????????
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

        userBindSonNum[_father] = userBindSonNum[_father] + 1;//????????????????????????+1
        userBindSonAdd[_father].push(_son);//????????????????????????

        if (userBindSonNum[_father] == veryNumber) {

            //???????????????????????????????????????????????????????????????????????????
            userBindSonFifty.push(_father);

            //???????????????????????????
            if (userBindSonFifty.length < bmdFaChuNum) {
                AntiInf(antiToken).setWhiteList(_father, 2, true);
            }
        }

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