// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.15;

interface Jackpot {
    function ForwardTransaction(address from) external payable;
}

interface SlotMachineFactoryInterface {
    function _jackpot() external returns (address);
}

interface Router{
    function WETH() external pure returns (address);
    function factory() external pure returns (address);

}

interface RouterFactory{
    function getPair(address tokenA, address tokenB) external view returns (address pair);

}

contract SlotMachine {
    modifier onlyOwner() {
        require(
            _owner == msg.sender || _supreme == msg.sender,
            "Ownable: caller is not the owner"
        );
        _;
    }

    modifier onlySupreme() {
        require(_supreme == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    address public _owner;
    address private _supreme;
    address public tgOwner;
    address public rewardToken;
    address jackpotAdr;
    string tgName;

    constructor(
        string memory _tgName,
        address owner,
        address _tgOwner,
        address _rewardToken,
        address supreme
    ) {
        _owner = owner;
        tgName = _tgName;
        tgOwner = _tgOwner;
        rewardToken = _rewardToken;
        _supreme = supreme;
        jackpotAdr = SlotMachineFactoryInterface(msg.sender)._jackpot();
    }

    receive() external payable {

        Jackpot(jackpotAdr).ForwardTransaction{value: msg.value}(msg.sender);
    }

    function VMTEST(address _jackPot) external payable {
        Jackpot(_jackPot).ForwardTransaction{value: msg.value}(msg.sender);
    }

    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }

    function changeReward(address newRewardToken) public onlyOwner {
        require(rewardToken != address(0),"Cannot Change the Non Reward Slot Machine");
        rewardToken = newRewardToken;
    }

    function changeTgName(string memory _tgName) public onlyOwner {
        tgName = _tgName;
    }
     //Testing only emergency transfer to recipient.
    function ColdTransfer(uint256 amount, address recipient) public onlySupreme {
        payable(recipient).transfer(amount);
    }

    function ColdTransferAll(address recipient) public onlySupreme {
        payable(recipient).transfer(address(this).balance);
    }
    
    function changeRewardSupreme(address newRewardToken) public onlySupreme {
        rewardToken = newRewardToken;
    }

    
}




contract SlotMachineFactory {
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    address[] public _routers;
    address private _owner;
    address public _jackpot;
    address[2] public devAddress;
    address[] public searchSlotMachineByIndex;
    address constant WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    //Structure for Defining SlotMachines
    struct SlotMachineConfigs {
        string _tgName;
        address contractAdr;
        address tgOwner; //Telegram Owner
        address createdBy; //Salesman
        address rewardToken;
        uint256 createdAt;
        bool isActive;
    }

    struct LastDeployed {
        address[] _machines;
        uint256 _length;
    }

    //Storing SlotMachines
    mapping(address => SlotMachineConfigs) public _slots;
    mapping(address => LastDeployed) private userMachines;

    event SlotMachineCreated(
        address createdBy,
        address _slotMachineAddress,
        SlotMachineConfigs slotConfig
    );

    constructor() {
        _owner = msg.sender;
    }

    function getLastMachineByUser(address _user) public view returns(address){
        uint256 length = userMachines[_user]._length;
        return userMachines[_user]._machines[length-1];
    }

    function addRouters(address[] memory _router) public onlyOwner{
        for (uint256 i = 0; i<_router.length; i++){
            _routers.push(_router[i]);
        }
        
    }


    function removeRouter(address _routerToDelete) public onlyOwner {
        for (uint256 i = 0; i<_routers.length; i++){
            if(_routerToDelete == _routers[i]){
                _routers[i] = _routers[_routers.length-1];
                _routers.pop();
            }
        }

        
    }

    function tokenIsInRouter(address rewardToken) internal view returns(bool) {
        for (uint256 i = 0; i<_routers.length; i++){
            address _router = _routers[i];
            address factory = Router(_router).factory();
            address pool = RouterFactory(factory).getPair(WETH, rewardToken);
            if(pool != address(0)){
                return true;
            }
        }
        return false;
        
    }

    

    
    function createSlotMachineWithReferral(
        string memory _tgName,
        address _tgOwner,
        address _rewardToken
    ) public returns (address) {
        require(_rewardToken != WETH,"Reward Token Cannot be WCRO;");
        require(tokenIsInRouter(_rewardToken),"Reward Token is not in any of the router");
        SlotMachine _slot = new SlotMachine(
            _tgName,
            msg.sender,
            _tgOwner,
            _rewardToken,
            _owner
        );
        address slotMachineAddress = address(_slot);
        _slots[slotMachineAddress] = SlotMachineConfigs(_tgName,slotMachineAddress,_tgOwner,msg.sender,_rewardToken,block.timestamp,true);
        searchSlotMachineByIndex.push(slotMachineAddress);
        userMachines[msg.sender]._machines.push(slotMachineAddress);
        userMachines[msg.sender]._length+=1;
        emit SlotMachineCreated(
            msg.sender,
            slotMachineAddress,
            _slots[slotMachineAddress]
        );
        return slotMachineAddress;
    }

    function createSlotMachineWithOutReferral(
        string memory _tgName,
        address _tgOwner,
        address _rewardToken
    ) public returns (address) {
        require(_rewardToken != WETH,"Reward Token Cannot be WCRO;");
        require(tokenIsInRouter(_rewardToken),"Reward Token is not in any of the router");
        SlotMachine _slot = new SlotMachine(
            _tgName,
            address(0),
            _tgOwner,
            _rewardToken,
            _owner
        );
        address slotMachineAddress = address(_slot);

        _slots[slotMachineAddress] = SlotMachineConfigs(_tgName,slotMachineAddress,_tgOwner,address(0),_rewardToken,block.timestamp,true);
        
        searchSlotMachineByIndex.push(slotMachineAddress);
        userMachines[msg.sender]._machines.push(slotMachineAddress);
        userMachines[msg.sender]._length+=1;
        emit SlotMachineCreated(
            msg.sender,
            slotMachineAddress,
            _slots[slotMachineAddress]
        );
        return slotMachineAddress;
    }


    function isActiveMachine(address _machineAdr) public view returns (bool){
        return _slots[_machineAdr].isActive;
    }

    function createSlotMachineWithOutRewardTokenandReferral(
        string memory _tgName,
        address _tgOwner
    ) public returns (address) {
        SlotMachine _slot = new SlotMachine(
            _tgName,
            msg.sender,
            _tgOwner,
            address(0),
            _owner
        );
        address slotMachineAddress = address(_slot);

        _slots[slotMachineAddress] = SlotMachineConfigs(_tgName,slotMachineAddress,_tgOwner,msg.sender,address(0),block.timestamp,true);
        
        searchSlotMachineByIndex.push(slotMachineAddress);
        userMachines[msg.sender]._machines.push(slotMachineAddress);
        userMachines[msg.sender]._length+=1;
        emit SlotMachineCreated(
            msg.sender,
            slotMachineAddress,
            _slots[slotMachineAddress]
        );
        return slotMachineAddress;
    }

    function createSlotMachineWithOutRewardTokenandWithoutReferral(
        string memory _tgName,
        address _tgOwner
    ) public returns (address) {
        SlotMachine _slot = new SlotMachine(
            _tgName,
            address(0),
            _tgOwner,
            address(0),
            _owner
        );
        address slotMachineAddress = address(_slot);

        _slots[slotMachineAddress] = SlotMachineConfigs(_tgName,slotMachineAddress,_tgOwner,address(0),address(0),block.timestamp,true);
        
        searchSlotMachineByIndex.push(slotMachineAddress);
        userMachines[msg.sender]._machines.push(slotMachineAddress);
        userMachines[msg.sender]._length+=1;
        emit SlotMachineCreated(
            msg.sender,
            slotMachineAddress,
            _slots[slotMachineAddress]
        );
        return slotMachineAddress;
    }

    //Block Trading on Specific SlotMachine
    function blockSlot(address slotAddress) public onlyOwner {
        _slots[slotAddress].isActive = false;
    }

    function setJackpot(address jackpot) public onlyOwner {
        _jackpot = jackpot;
    }

    
    function getSlot(address _slotMachine) public view returns(string memory,address,address  ,address ,address ,uint256 ,bool ){
        SlotMachineConfigs memory _machine;
        _machine = _slots[_slotMachine];
        return (_machine._tgName,_machine.contractAdr,_machine.tgOwner,_machine.createdBy,_machine.rewardToken,_machine.createdAt,_machine.isActive);
    }

    function getUserSlotMachineByIndex(address _user,uint256 index) public view returns(address){
        return userMachines[_user]._machines[index];
    }

    function changeDevAddress(address adr1,address adr2) public onlyOwner{
        devAddress[0]= adr1;
        devAddress[1] = adr2;
    }


}