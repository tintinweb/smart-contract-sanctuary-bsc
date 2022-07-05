/**
 *Submitted for verification at BscScan.com on 2022-07-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract BSCGiveGame {

    address public owner;

    struct Table{
        uint thValue;
        uint maxProfit;
        uint refProfit;
        uint randomProfit;
        uint randomRefProfit;
    }

    mapping(address => uint256) public address2id;
    mapping(uint256 => address) public id2address;
    mapping(uint256 => uint256) public id2refid;

    mapping(uint256 => uint256) public id2counttable;
    mapping(uint256 => mapping(uint256 => uint256)) public tableNid2profit;
    mapping(uint256 => mapping(uint256 => uint256)) public tableNid2profitRef;
    mapping(uint256 => mapping(uint256 => uint256)) public tableNid2profitRandRef;
    mapping(uint256 => mapping(uint256 => uint256)) public tableNid2profitLost;

    uint256 public counter;

    Table[] public tables;

    uint256[][] public userintables; // Number of table / User
    uint256[] temp;
    uint256[] randwinners;

    event newUser(address indexed to, uint256 id);
    event buy(uint256 id, uint256 numberTable);
    event payToUser(address indexed to, uint value);
    event winners(uint256[] to);
    event userGetMaxProfit(uint256 to);

    constructor () {
        owner = msg.sender;
        address2id[owner] = 0;
        id2address[0] = owner;
        counter = 1;
        id2counttable[0] = 10;
        initTables();
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function buyTable() public payable{
        uint256 ref = 0;
        buyTable(ref);
    }

    function buyTable(uint256 ref) public payable{
        require(msg.value > 0, "Not Money");
        uint256 idUser = address2id[msg.sender];
        if(idUser == 0){
            idUser = registration(ref);
        } 
        uint256 numberTable = 1;
        while(true){
            require(numberTable < tables.length, "Incorrect input sum");
            if(msg.value == tables[numberTable].thValue && id2counttable[idUser] == numberTable - 1){
                id2counttable[idUser] = numberTable;
                payRandomProfit(numberTable, msg.value);

                userintables[numberTable].push(idUser);  

                payRefProfit(idUser, numberTable, msg.value, false);    
                emit buy(idUser,numberTable);
                break;      
            }
            numberTable++;        
        }

    }

    function registration(uint256 ref) private returns (uint256){
        id2address[counter] = msg.sender;
        address2id[msg.sender] = counter;
        id2refid[counter] = ref;
        counter += 1;
        emit newUser(msg.sender, counter-1);
        return counter - 1;
    }

    function initTables() private{
        tables.push(Table(0,0,0,0,0));
        tables.push(Table(100000000000000000,250,30,40,30));
        tables.push(Table(200000000000000000,250,30,40,30));
        tables.push(Table(400000000000000000,250,30,40,30));
        tables.push(Table(800000000000000000,250,30,40,30));
        tables.push(Table(1600000000000000000,350,30,45,25));
        tables.push(Table(3200000000000000000,350,30,45,25));
        tables.push(Table(6400000000000000000,350,30,45,25));
        tables.push(Table(12800000000000000000,450,30,50,20));
        tables.push(Table(25600000000000000000,450,30,50,20));
        tables.push(Table(51200000000000000000,9999999999,30,55,15));

        for(uint256 i = 0; i <= tables.length; i++){
            userintables.push();
        }
    }

    function payRefProfit(uint256 idUser, uint256 numberTable, uint val, bool rand) private{
        uint256 refid = idUser;
        uint _val = 0;
        while(true){
            refid = id2refid[refid];
            if(id2counttable[refid] >= numberTable){        
                if(rand){
                    _val = val * tables[numberTable].randomRefProfit / (10 * 100);
                    tableNid2profitRandRef[numberTable][refid] += _val;
                }else{
                    _val = val * tables[numberTable].refProfit / 100;
                    tableNid2profitRef[numberTable][refid] += _val;
                }
                pay(id2address[refid], _val); 
                break; 
            }else{
                _val = rand ? val * tables[numberTable].randomRefProfit / (10 * 100) : val * tables[numberTable].refProfit / 100;
                tableNid2profitLost[numberTable][refid] += _val;           
            }               
        }
    }

    function payRandomProfit(uint256 numberTable, uint val) private{
        delete randwinners;
        temp = userintables[numberTable];
        if(userintables[numberTable].length <= 5){
            for(uint256 i = 0; i < userintables[numberTable].length; i++){
                randwinners.push(userintables[numberTable][i]);
            }
        }else{
            uint256 r = 0;
            for(uint256 i = 1; i <= 5; i++){
                r = random(temp.length,i);
                randwinners.push(temp[r]);
                temp[r] = temp[temp.length-1];
                temp.pop();
            }
        }   
        emit winners(randwinners);
        for(uint256 i = 0; i < randwinners.length; i++){
            uint256 _val = val * tables[numberTable].randomProfit / (5 * 100);
            pay(id2address[randwinners[i]], _val);
            tableNid2profit[numberTable][randwinners[i]] += _val;

            payRefProfit(randwinners[i], numberTable, val, true);
            payRefProfit(id2refid[randwinners[i]], numberTable, val, true);
            if(tableNid2profit[numberTable][randwinners[i]] * 100 / tables[numberTable].thValue > tables[numberTable].maxProfit) {
                for(uint256 j = 0; j < userintables[numberTable].length; j++){
                    if(userintables[numberTable][j] == randwinners[i]){
                        userintables[numberTable][j] = userintables[numberTable][userintables[numberTable].length-1];
                        userintables[numberTable].pop();
                        emit userGetMaxProfit(randwinners[i]);
                        break;
                    }
                }
            }
        }
    }

    function pay(address _address, uint val) private{
        address payable _to = payable(_address); 
        _to.transfer(val); 
        emit payToUser(_to,val);
    }

    function random(uint256 max, uint256 salt) public view returns(uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp * salt, block.difficulty, msg.sender))) % max;
    }

    function getCountUsersInTable(uint256 numberTable) public onlyOwner view returns(uint256) {
        return userintables[numberTable].length;
    }

    function getTablesInfo() public view returns(uint256[] memory, uint256[] memory, uint256[] memory, uint256[] memory, uint256[] memory){
        uint256[] memory thValue = new uint256[](tables.length);
        uint256[] memory maxProfit = new uint256[](tables.length);
        uint256[] memory refProfit = new uint256[](tables.length);
        uint256[] memory randomProfit = new uint256[](tables.length);
        uint256[] memory randomRefProfit = new uint256[](tables.length);
        for(uint256 i=1; i<tables.length; i++){
            thValue[i-1] = tables[i].thValue;
            maxProfit[i-1] = tables[i].maxProfit;
            refProfit[i-1] = tables[i].refProfit;
            randomProfit[i-1] = tables[i].randomProfit;
            randomRefProfit[i-1] = tables[i].randomRefProfit;
        }
        return (thValue, maxProfit, refProfit, randomProfit, randomRefProfit);
    }
    
    function getProfit(uint256 id) public view returns(uint256[] memory){
        uint256[] memory arr = new uint256[](tables.length);
        for(uint256 i = 1; i < tables.length; i++){
            arr[i-1] = tableNid2profit[i][id];
        }           
        return arr;
    }

     function getProfitRef(uint256 id) public view returns(uint256[] memory){
        uint256[] memory arr = new uint256[](tables.length);
        for(uint256 i = 1; i < tables.length; i++){
            arr[i-1] = tableNid2profitRef[i][id];
        }           
        return arr;
    }   

    function getProfitRandRef(uint256 id) public view returns(uint256[] memory){
        uint256[] memory arr = new uint256[](tables.length);
        for(uint256 i = 1; i < tables.length; i++){
            arr[i-1] = tableNid2profitRandRef[i][id];
        }           
        return arr;
    }   

    function getProfitLost(uint256 id) public view returns(uint256[] memory){
        uint256[] memory arr = new uint256[](tables.length);
        for(uint256 i = 1; i < tables.length; i++){
            arr[i-1] = tableNid2profitLost[i][id];
        }           
        return arr;
    }   

    function withdrawAll() public onlyOwner {
        address _contract = address(this);
        address payable _to = payable(owner);
        _to.transfer(_contract.balance);
    }

}