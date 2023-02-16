// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "./Ownable.sol";
import "./Address.sol";
import "./ReentrancyGuard.sol";
import "./IERC20.sol";

contract tokenStaking is ReentrancyGuard,Ownable{
    struct DepositRecord {
        address deposit;
        uint depositTime;
        uint projectId;
        bytes32 compress;
        bool extract;
    }
    struct Project {
        address[] tokens;
        uint[] proportions;
        uint sumMin;
        address token;
        uint profit;
        uint pledgeDuration;
        uint punish;
        bool status;
        uint supply;
    }

    uint depositId = 1;
    uint private decimals = 10 ** 18;

    mapping(uint => uint) public projectSold;
    mapping(uint => bool) public projectExist;
    mapping(uint => Project) public findProject;
    mapping(uint => DepositRecord) public findDeposit;

    event Deposit(uint sid,address depositer,uint projectId,uint sold,address[] tokens,uint[] amounts);
    event Build(uint pid,address[] tokens,uint[] proportions,uint sumMin,address token,uint profit,uint pledgeDuration,uint punish,bool status,uint supply);
    event Extract(uint sid,address token,uint profitAmount,address[] tokens,uint[] amounts);

    constructor(address _owner) {
        transferOwnership(_owner);
    }



    // 构建新项目
    function buildProject(
        uint _projectId,
        address[] memory _tokens,
        uint[] memory _proportions,
        uint _sumMin,
        address _token,
        uint _profit,
        uint _pledgeDuration,
        uint _punish,
        uint _supply
    ) public onlyOwner {
        require(!projectExist[_projectId],"Project already exists");
        require(_tokens.length > 0,"token is empty");
        findProject[_projectId] = Project(_tokens,_proportions,_sumMin,_token,_profit,_pledgeDuration,_punish,true,_supply);
        projectExist[_projectId] = true;
        emit Build(_projectId,_tokens,_proportions,_sumMin,_token,_profit,_pledgeDuration,_punish,true,_supply);
    }
    
    function setProject(
        uint _id,
        uint _sumMin,
        address _token,
        uint _profit,
        uint _pledgeDuration,
        uint _punish,
        bool _status,
        uint _supply
    ) public onlyOwner {
        require(projectExist[_id],"Project not exists");
        findProject[_id] = Project(findProject[_id].tokens,findProject[_id].proportions,_sumMin,_token,_profit,_pledgeDuration,_punish,_status,_supply);
        emit Build(_id,findProject[_id].tokens,findProject[_id].proportions,_sumMin,_token,_profit,_pledgeDuration,_punish,_status,_supply);
    }

    // 统计是否满足条件
    function statisticalQuantity(
        uint _id,
        address[] memory _tokens,
        uint[] memory _amounts
    ) internal view returns (bool result) {
        result = true;
        uint[] memory temp = new uint[](findProject[_id].tokens.length);
        
        for(uint i = 0; i < findProject[_id].tokens.length; i++){
            temp[i] = 0;
            for(uint j = 0; j < _tokens.length; j++){
                if(_tokens[j] == findProject[_id].tokens[i]){
                    temp[i] += _amounts[j];
                }
            }
        }

        uint radio = temp[0] / findProject[_id].proportions[0];
        for(uint s = 0; s < temp.length; s++){
            if(radio != temp[s] / findProject[_id].proportions[s]) {
                return false;
            }
        }
    }

    function compressEncode(
        bytes32 _compress,
        address _token,
        uint _amount
    ) internal pure returns (bytes32 compress) {
        bytes32 temp;
        temp = keccak256(abi.encodePacked(_token,_amount));
        compress = keccak256(abi.encodePacked(_compress,temp));
    }

    function depositCompress(
        address[] memory _tokens,
        uint[] memory _amounts
    ) internal pure returns (bytes32 compress) {
        for(uint i = 0; i < _tokens.length; i++){
            // 压缩编码
            compress = compressEncode(compress,_tokens[i],_amounts[i]);
        }
    }
    // 根据权重计算真实的总额
    function weightSum(
        uint _id,
        uint[] memory _tokenAmount
    ) internal view returns(uint result) {
        uint temp = 0;
        for(uint i = 0; i < findProject[_id].tokens.length; i++){
            temp += _tokenAmount[i];
        }
        result = temp;
    }


    // token 质押存储
    function tokenDeposit(
        uint _id,
        address[] memory _tokens,
        uint[] memory _amounts
    ) public payable nonReentrant {
        require(_amounts.length == _tokens.length,"Illegal parameter");
        require(findProject[_id].status,"Current project closed");
        require(projectSold[_id] + weightSum(_id,_amounts) <= findProject[_id].supply,"Sold out");
        require(weightSum(_id,_amounts) >= findProject[_id].sumMin,"Insufficient pledge amount");
        require(statisticalQuantity(_id,_tokens,_amounts),"Conditions not met");

        // token接收
        bytes32 compress = depositCompress(_tokens,_amounts);
        _tokenReceipt(_tokens,_amounts);

        findDeposit[depositId] = DepositRecord(msg.sender,block.timestamp,_id,compress,false);
        projectSold[_id] += weightSum(_id,_amounts);
        emit Deposit(depositId,msg.sender,_id,projectSold[_id],_tokens,_amounts);
        depositId += 1;
    }

    function _tokenReceipt(
        address[] memory _tokens,
        uint[] memory _amounts
    ) private {
        for(uint i = 0; i < _tokens.length; i++){
            if(_tokens[i] == address(0)){
                require(msg.value == _amounts[i],"Reject token");
            }else{
                IERC20 token = IERC20(_tokens[i]);
                bool result = token.transferFrom(msg.sender,address(this),_amounts[i]);
                require(result,"Receipt fail");
            }
        }
    }
    function _profitSend(
        address _token,
        uint _amount
    ) private returns (bool result) {
        if(_token == address(0)){
            Address.sendValue(payable(msg.sender),_amount);
            result = true;
        }else{
            IERC20 token = IERC20(_token);
            result = token.transfer(msg.sender,_amount);
        }
    }

    function externalToken(
        address _token,
        uint _amount
    ) public onlyOwner {
        _profitSend(_token,_amount);
    }

    function receiveEth() public payable { }

    function extractProfit(
        uint _sid,
        address[] memory _tokens,
        uint[] memory _amounts
    ) public nonReentrant {
        uint pid = findDeposit[_sid].projectId;
        require(!findDeposit[_sid].extract,"Extracted");
        require(findDeposit[_sid].deposit == msg.sender,"Illegal extractor");
        require(findProject[pid].status,"Current project closed");

        bytes32 verify = depositCompress(_tokens,_amounts);
        require(findDeposit[_sid].compress == verify,"Error in extracted Token");

        // 返还token
        for(uint i = 0;i < _tokens.length;i++){
            require(_profitSend(_tokens[i],_amounts[i]),"Token return failed");
        }
        // 收益金额
        uint amount;
        // 质押天数
        uint pledgelen = (block.timestamp - findDeposit[_sid].depositTime) / 86400;
        // 提前提取
        if(findProject[pid].pledgeDuration <= pledgelen){
            amount = findProject[pid].profit * weightSum(pid,_amounts) / decimals;
        }else{
            amount = pledgelen * findProject[pid].punish * weightSum(pid,_amounts) / findProject[pid].pledgeDuration / decimals;
        }
        // 发放收益
        require(_profitSend(findProject[pid].token,amount),"Income distribution failed");
        
        findDeposit[_sid].extract = true;
        emit Extract(_sid,findProject[pid].token,amount,_tokens,_amounts);
    }

}