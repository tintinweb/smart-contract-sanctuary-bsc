// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

interface Token777 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function GenerateTokensForWinners(address _winnerAddress, uint256 amount) external;

    /**
     * @dev Get ciruculating supply
     * 
     *
     * Returns an integer value indicating the circulating supply.
     *
     */
    function getCirculatingSupply() external view returns (uint256);
}

pragma solidity ^0.8.7;

import "./VRFCoordinatorV2Interface.sol";
import "./VRFConsumerBaseV2.sol";

contract Bet is VRFConsumerBaseV2 {
    VRFCoordinatorV2Interface COORDINATOR;

    uint64 s_subscriptionId;

    Token777 public token;

    address vrfCoordinator = 0xc587d9053cd1118f25F645F9E08BB98c9712A4EE;

    bytes32 keyHash = 0xba6e730de88d94a5510ae6613898bfb0c3de5d16e609c5b7da808747125506f7;

    uint32 callbackGasLimit = 1000000;

    uint16 requestConfirmations = 3;
    uint256 public vRes ; 

    uint32 numWords =  1;

    uint256[] public s_randomWords;
    uint256 public s_requestId;
    uint16 public setterN = 0; 
    uint256 public maxbet = 7770000*10**18;


    mapping(uint256 => address) private _wagerInit; 
    mapping(address => uint256) private _wagerInitAmount;
    mapping(address => uint16) public LatestRes; 
    mapping(address => uint16) private CanPlay ; 

    address public burnaddy = 0x000000000000000000000000000000000000dEaD ; 
    address s_owner;  
    address public creator =  0x658ad555Ec8A37d3DA5acF1d652DF4E20a18Aae7;

    constructor(uint64 subscriptionId) VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_owner = msg.sender;
        s_subscriptionId = subscriptionId;
        
    }
    function SetToken(Token777 _token)public {
        require(msg.sender == creator);
        require(setterN == 0);
        token = _token;
        setterN = 1 ; 
    }

    function ChangeMaxBet(uint256 change_value)public {
        require(msg.sender== creator);
        require(change_value <15540000*10**18);
        require(change_value >3885000*10**18 );
        change_value = maxbet;
    }


    function requestRandomWords(uint256 _amount) external {
        require(CanPlay[msg.sender]==0, 'bet already placed');
        require(_amount <maxbet, 'too big');
        require((_amount/10000)*10000 == _amount, 'too small');
        require(token.balanceOf(msg.sender) >= _amount);
        token.transferFrom(msg.sender,burnaddy , _amount);

        s_requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
    
        _wagerInit[s_requestId] = msg.sender;
        _wagerInitAmount[msg.sender] = _amount;   

        LatestRes[msg.sender] = 0 ; 
        CanPlay[msg.sender] = 1; 
    }

    function fulfillRandomWords  (
       uint256 s_requestId, /* requestId */
       uint256[] memory randomWords
    ) internal override {
    uint256 s_randomRange = (randomWords[0] % 100) + 1;
    _settleBet(s_requestId,s_randomRange);
   }

   function _settleBet(uint256 requestId, uint256 randomNumber) private {
        address _user = _wagerInit[requestId];
        require(_user != address(0), 'coin flip record does not exist');

        uint256 _amountWagered = _wagerInitAmount[_user];

        vRes = randomNumber ; 
            
        if (randomNumber > 55 && randomNumber < 72){
            //20 percent
            uint WinAmount = (_amountWagered/100) *20 ; 
            token.GenerateTokensForWinners( _user, _amountWagered + WinAmount);
            LatestRes[_user] = 1 ;
            
        } else if (randomNumber > 71 && randomNumber < 86 ){
            //2x
            uint WinAmount = _amountWagered*2;
            token.GenerateTokensForWinners(_user, WinAmount); 
            LatestRes[_user] = 2 ;

        } else if (randomNumber > 85 && randomNumber < 97){
            //3x
            uint WinAmount = _amountWagered*3;
            token.GenerateTokensForWinners(_user, WinAmount); 
            LatestRes[_user] = 3 ;

        } else if(randomNumber > 96 && randomNumber < 100){
            //4x
            uint WinAmount = _amountWagered*4;
            token.GenerateTokensForWinners(_user, WinAmount); 
            LatestRes[_user] = 4 ;

        } else if(randomNumber ==100){
            //10x
            uint WinAmount = _amountWagered*10;
            token.GenerateTokensForWinners(_user, WinAmount); 
            LatestRes[_user] = 5 ;
        }
        else {
            LatestRes[_user] =9 ; 
        }
        CanPlay[_user] = 0; 
        }

        
}