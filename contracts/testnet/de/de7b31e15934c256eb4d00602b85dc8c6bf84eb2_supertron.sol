/**
 *Submitted for verification at BscScan.com on 2023-04-01
*/

// pragma solidity ^0.8.7;

interface TRC20 {
    function totalSupply() external view returns (uint256 supply);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function transfer(address _to, uint256 _value)
        external
        returns (bool success);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);

    function approve(address _spender, uint256 _value)
        external
        returns (bool success);

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256 remaining);

    function decimals() external view returns(uint256 digits);

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
}

contract supertron{

    address owner;
    uint256 idProvider = 3999;
    TRC20 public superTron;
    uint256 [] LevelIncomePercentage = [10,10,15,15,20,30];

    struct userDetail{

        uint256 userID;
        uint256 referBy;
        address referByAddress;
        uint256 UserAmount;
        uint256 UserWithdrawl;
        uint256 userLastTimeRestakingAmount;
        uint256 totaldirect;
        uint256 totalIncentiveEarned;
        bool    oldUser ;
    
    }

        

    mapping(address => userDetail)public userInvestmentDetail;
    mapping(address => mapping(uint256 => uint256)) public userLevelIncomeDetail; 
    mapping(address => uint256) public UserId;
    mapping(uint256 => address) public idToAddress;
    mapping(uint256 => bool) public isExist;


    modifier onlyOwner(){
        require(msg.sender == owner);
       _;
    }

    constructor(address _owner ){
            owner = _owner;
            superTron = TRC20(0x2a70E7457efC2CED30eFF86De13c5ff020bF3374);
    }   

    function Invest( uint256 _amount, uint256 refBy ) public payable {

        require(isExist[refBy] == true ,"referal user Not Found");
        if(userInvestmentDetail[msg.sender].oldUser ==false ){
        require(msg.value >= 100000000000000000000,"Investment Package must be equal to Hundred Tron");
        }else{
            
            require(msg.value >= ((userInvestmentDetail[msg.sender].UserAmount*20/100)),"Please Enter Proper Fees Reinvesting fess"); 
        }
            
        if(userInvestmentDetail[msg.sender].userID==0){
              userInvestmentDetail[msg.sender].userID=idProvider;
              UserId[msg.sender]=idProvider;
              idToAddress[idProvider]=msg.sender;
              isExist[idProvider]==true;
        }

        if( userInvestmentDetail[msg.sender].referBy == 0){
               
               userInvestmentDetail[msg.sender].referBy == refBy;
               userInvestmentDetail[msg.sender].referByAddress = idToAddress[refBy];
               userInvestmentDetail[idToAddress[refBy]].totaldirect++;
        }
            userInvestmentDetail[msg.sender].UserAmount=_amount;    

    }

    function Withdraw() public {

        require(userInvestmentDetail[msg.sender].UserAmount!=0,"Zero Balance");

            uint256 userShare = (userInvestmentDetail[msg.sender].UserAmount*80)/100;
            uint256 reInvestShare = (userInvestmentDetail[msg.sender].UserAmount*20)/100;

               payable(msg.sender).transfer(userShare);    

                Invest(reInvestShare,userInvestmentDetail[msg.sender].referBy);
               address _referrer = userInvestmentDetail[msg.sender].referByAddress;

            for (uint8 i = 1; i < 6; i++) {
                if (_referrer != address(0)){


                    if(userInvestmentDetail[msg.sender].totaldirect >= i){
                             payable(msg.sender).transfer((userInvestmentDetail[msg.sender].UserAmount*LevelIncomePercentage[i])/100);    
                                userInvestmentDetail[_referrer].totalIncentiveEarned +=(userInvestmentDetail[msg.sender].UserAmount*LevelIncomePercentage[i])/100;
                        }
                    }

                if ( userInvestmentDetail[_referrer].referByAddress !=address(0))
                    _referrer = userInvestmentDetail[_referrer].referByAddress;
                else break;
                }
            } 

    function withdrawl(uint256 ammt) public onlyOwner {

        require(address(this).balance >= ammt, "insufficient contract balance");
        payable(msg.sender).transfer(ammt);
    
    }


 receive() external payable {}



    }