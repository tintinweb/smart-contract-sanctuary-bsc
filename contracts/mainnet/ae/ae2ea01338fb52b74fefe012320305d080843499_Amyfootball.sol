/**
 *Submitted for verification at BscScan.com on 2022-06-21
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16 <0.6.9;
pragma experimental ABIEncoderV2;
//WISHMELUCK
interface tokenRecipient {
    function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external;
}

contract Amyfootball {
    string public name;
    string public symbol;
    uint8 public decimals = 6;
    uint256 public totalSupply;
    address payable public fundsWallet;
    uint256 public targetControl;
    uint256 public finalBlock;
    uint256 public rewardTimes;
    uint256 public constantDecimal;
    uint256 public premined;
    uint256 public stModulo;
    uint256 public stCancel;


    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Burn(address indexed from, uint256 value);

    constructor(
        uint256 initialSupply,
        string memory tokenName,
        string memory tokenSymbol
    ) public {
        initialSupply = 73656000  * 10 ** uint256(decimals);
        tokenName = "Amyfootball";
        tokenSymbol = "AMYF";
        finalBlock = 0;
        stModulo = 31173;        
        stCancel = 7776000;        
        constantDecimal = (10**uint256(decimals)); // Ödül Miktarı
        targetControl = 100  * 10 ** uint256(decimals);
        fundsWallet = msg.sender;
        premined = 16344000 * 10 ** uint256(decimals);
        balanceOf[msg.sender] = premined;
        balanceOf[address(this)] = initialSupply;
        totalSupply =  initialSupply + premined;
        name = tokenName;
        symbol = tokenSymbol;
    }

    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != address(0x0));
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, address(this), _extraData);
            return true;
        }
    }

    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough
        balanceOf[msg.sender] -= _value;            // Subtract from the sender
        totalSupply -= _value;                      // Updates totalSupply
        emit Burn(msg.sender, _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);                // Check if the targeted balance is enough
        require(_value <= allowance[_from][msg.sender]);    // Check allowance
        balanceOf[_from] -= _value;                         // Subtract from the targeted balance
        allowance[_from][msg.sender] -= _value;             // Subtract from the sender's allowance
        totalSupply -= _value;                              // Update totalSupply
        emit Burn(_from, _value);
        return true;
    }

    function changeToStr(uint256 v) internal pure returns(string memory str) {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = byte(uint8(48 + remainder));
        }
        bytes memory s = new bytes(i + 1);
        for (uint j = 0; j <= i; j++) {
            s[j] = reversed[i - j];
        }
        str = string(s);
    }

    function joinStrings(string memory a, string memory b) internal pure returns (string memory) {
        return string(abi.encodePacked(a,"-",b));
    }
   

    function amyThisBlockHash() public view returns (uint256) {
            return uint256(blockhash(block.number-1));
    }

    function amyBHashAlgo(uint256 _blocknumber) public view returns(uint256, uint256){
        uint256 dataBll = uint256(blockhash(_blocknumber)) % stModulo;
        return (dataBll, block.number-1);
    }

    function findBlockWinn() public view returns (uint256, uint256) {
        uint256 dataBll = uint256(blockhash(block.number-1)) % stModulo;
        return (dataBll, block.number-1);
    }

    struct amyProgramInfo {
      uint256 _stakebeginning;
      uint256 _userstakes;
    }

    address[] totalStakers;

    mapping (address => amyProgramInfo) amyStakeDetails;

    struct prizeDetails {
        uint256 _amyyr;
        bool _ifEarnPrize;
        bool _ifShouldProcess;
    }

    mapping (string => prizeDetails) nprizeDetails;

    struct nBlockInformations {
        uint256 _bNoww;
        uint256 _amyTotalInvest;
    }

    mapping (uint256 => nBlockInformations) amyBlockChecker;

    struct activeSupporter {
        address bUser;
    }

    mapping(uint256 => activeSupporter[]) aSupporter;


    function totalSupportersNum() view public returns (uint256) {
        return totalStakers.length;
    }


    function amyaddressCrypt() view public returns (uint256) {
        return uint256(msg.sender) % 10000000000;
    }    


    function supporterTime(address _sendder) view public returns(bool){

        if(amyStakeDetails[_sendder]._stakebeginning == 0)
        {
            return false;
        }
        else 
        {
            return true;
        }
        
    }

    function supporterStock(address _sendder) view public returns(uint256){

        if(amyStakeDetails[_sendder]._userstakes == 0)
        {
            return 0;
        } 
        else 
        {
            return amyStakeDetails[_sendder]._userstakes;
        }
        
    }

    function stakerTimeStart(address _sendder) view public returns(uint256){

        return amyStakeDetails[_sendder]._stakebeginning;
    }


    function stakerActiveTotal() view public returns(uint256) {
        return aSupporter[finalBlock].length; 
    }
   
   
    function amyCheckP()  private view returns(string memory) {
       return joinStrings(changeToStr(amyaddressCrypt()),changeToStr(finalBlock));
    }  
    
   
    function supporterShouldGoContrat(uint256 _checkBnumm) public returns (uint256)  { 
       require(supporterTime(msg.sender) == true);
       require((block.number-1) - _checkBnumm  <= 200);        
       require(amyStakeDetails[msg.sender]._stakebeginning + stCancel > now);   
       require(uint256(blockhash(_checkBnumm)) % stModulo == 1);
       
       if(amyBlockChecker[finalBlock]._bNoww + 1800 < now)       
       {
           finalBlock += 1;
           amyBlockChecker[finalBlock]._bNoww = now;
       }
       require(nprizeDetails[amyCheckP()]._amyyr == 0);

       amyBlockChecker[finalBlock]._amyTotalInvest += amyStakeDetails[msg.sender]._userstakes;
       nprizeDetails[amyCheckP()]._amyyr = now;
       nprizeDetails[amyCheckP()]._ifEarnPrize = false;
       nprizeDetails[amyCheckP()]._ifShouldProcess = true;
       aSupporter[finalBlock].push(activeSupporter(msg.sender));
       return 200;
   }

   
   function amyContratPrizeDist(uint256 _checkBnumm) public returns(uint256) { 
       require(supporterTime(msg.sender) == true);
       require((block.number-1) - _checkBnumm  > 200);        
       require(uint256(blockhash(_checkBnumm)) % stModulo == 1);
       require(amyStakeDetails[msg.sender]._stakebeginning + stCancel > now  ); 
       require(nprizeDetails[amyCheckP()]._ifEarnPrize == false);
       require(nprizeDetails[amyCheckP()]._ifShouldProcess == true);
       
       uint256 findTerm = finalBlock / 90;   
       

       uint256 termPrize = 409600 * constantDecimal;
       
       if(findTerm==0)
       {
           termPrize = 409600 * constantDecimal;
       }
       else if(findTerm==1)
       {
           termPrize = 204800 * constantDecimal;
       }
       else if(findTerm==2)
       {
           termPrize = 102400 * constantDecimal;
       }
       else if(findTerm==3)
       {
           termPrize = 51200 * constantDecimal;
       }
       else if(findTerm==4)
       {
           termPrize = 25600 * constantDecimal;
       }
       else if(findTerm==5)
       {
           termPrize = 12800 * constantDecimal;
       }
       else if(findTerm==6)
       {
           termPrize = 6400 * constantDecimal;
       }
       else if(findTerm==7)
       {
           termPrize = 3200 * constantDecimal;
       }
       else if(findTerm==8)
       {
           termPrize = 1600 * constantDecimal;
       }
       else if(findTerm==9)
       {
           termPrize = 800 * constantDecimal;
       }
       
       uint256 usersReward = (termPrize * (amyStakeDetails[msg.sender]._userstakes * 100) / amyBlockChecker[finalBlock]._amyTotalInvest) /  100;
       nprizeDetails[amyCheckP()]._ifEarnPrize = true;
       _transfer(address(this), msg.sender, usersReward);
       return usersReward;
   }

   function joinStakeProgram(uint256 amyuserstakeamount) public returns (uint256) {

      uint256 howmuchSupport = amyuserstakeamount * 10 ** uint256(decimals);     
      require(howmuchSupport >= 10 * 10 ** uint256(decimals)); 
      require(amyStakeDetails[msg.sender]._stakebeginning == 0);     
      targetControl +=  howmuchSupport;
      amyStakeDetails[msg.sender]._stakebeginning = now;
      amyStakeDetails[msg.sender]._userstakes = howmuchSupport;
      totalStakers.push(msg.sender);
      _transfer(msg.sender, address(this), howmuchSupport);
      return 200;
   }

   function supporterWantsToLeave() public returns(uint256) {
       require(supporterTime(msg.sender) == true);
       require(amyStakeDetails[msg.sender]._stakebeginning + stCancel < now  );
       amyStakeDetails[msg.sender]._stakebeginning = 0;
       _transfer(address(this),msg.sender,amyStakeDetails[msg.sender]._userstakes);
       return amyStakeDetails[msg.sender]._userstakes;
   }

   struct noteArea {
       uint256 _noteTime;
       uint256 _sendingWithNote;
       address _whoIsSending;
       string _noteText;
   }

  mapping(address => noteArea[]) noteInformations;

  function sendNoteWithAmy(uint256 _amount, address _to, string memory _memo)  public returns(uint256) {
      noteInformations[_to].push(noteArea(now, _amount, msg.sender, _memo));
      _transfer(msg.sender, _to, _amount);
      return 200;
  }

  function sendNoteWithout(address _to, string memory _memo)  public returns(uint256) {
      noteInformations[_to].push(noteArea(now,0, msg.sender, _memo));
      _transfer(msg.sender, _to, 0);
      return 200;
  }


  function NoteChecker(address _sendder, uint256 _index) view public returns(uint256,
   uint256,
   string memory,
   address) {

       uint256 rTime = noteInformations[_sendder][_index]._noteTime;
       uint256 rAmount = noteInformations[_sendder][_index]._sendingWithNote;
       string memory sMemo = noteInformations[_sendder][_index]._noteText;
       address sAddr = noteInformations[_sendder][_index]._whoIsSending;
       if(noteInformations[_sendder][_index]._noteTime == 0){
            return (0, 0,"0", _sendder);
       }else {
            return (rTime, rAmount,sMemo, sAddr);
       }
  }


   function NoteTotal(address _sendder) view public returns(uint256) {
       return  noteInformations[_sendder].length;
   }

   function joinNotes(string memory a, string memory b,string memory c,string memory d) internal pure returns (string memory) {
        return string(abi.encodePacked(a,"#",b,"#",c,"#",d));
   }

   function chAddrToStr(address _sendder) public pure returns(string memory) {
    bytes32 value = bytes32(uint256(_sendder));
    bytes memory alphabet = "0123456789abcdef";

    bytes memory str = new bytes(51);
    str[0] = "0";
    str[1] = "x";
    for (uint i = 0; i < 20; i++) {
        str[2+i*2] = alphabet[uint(uint8(value[i + 12] >> 4))];
        str[3+i*2] = alphabet[uint(uint8(value[i + 12] & 0x0f))];
    }
    return string(str);
}

   function justNoteCheck(address _sendder) view public returns(string[] memory) {
       
       uint total =  noteInformations[_sendder].length;
       string[] memory messages = new string[](total);
      
       for (uint i=0; i < total; i++) {
             
            messages[i] = joinNotes(changeToStr(noteInformations[_sendder][i]._noteTime),noteInformations[_sendder][i]._noteText,changeToStr(noteInformations[_sendder][i]._sendingWithNote),chAddrToStr(noteInformations[_sendder][i]._whoIsSending));
       }

       return messages;
   }

}