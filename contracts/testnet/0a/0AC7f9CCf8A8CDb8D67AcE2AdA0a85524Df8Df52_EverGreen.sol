/**
 *Submitted for verification at BscScan.com on 2023-02-05
*/

pragma solidity >=0.4.23 <0.7.0;

contract EverGreen{
    
    struct M4User {
        uint8 level; 
        mapping(uint => M4Matrix) M4;
    }
    
    struct E3 {
        address currentReferrer;
        address[] referrals;
        bool blocked;
        uint reinvestCount;
    }
    struct M4Matrix {
        uint id;
        address useraddress;
        uint upline;
        uint8 partnercount;
        uint partnerdata;
        uint8 reentry;
    }
   
   struct User {
        uint id;
        address referrer;
        uint8 partnercount;
        uint8 maxlevel;
        mapping(uint8 => address[]) partners;
        mapping(uint8 => uint[]) E5Matrix;
        mapping(uint8 => bool) activeE3Levels;
        mapping(uint8 => E3) E3Matrix;
    }

    struct M4info{
        uint8 matrix;
        uint8 mxlvl;
        uint8 mxrety;
        uint topid;
        uint newid;
        uint benid;
        uint botid;
       
    }

   
    

    mapping(address => User) public users;
    mapping(uint8 => M4User) public M4users;
    mapping(uint => address) public userIds;
    mapping(address => uint) public balances; 
    mapping(address => uint) public roles; 
    mapping(uint8 => uint[]) public L5Matrix;
    
    uint public lastUserId = 2;
    uint8 public constant LAST_LEVEL = 13;
    address public owner;
    uint8[14] private rentmatrx = [0,1,1,1,1,2,4,2,2,2,2,2,3,3];
    uint8[14] private rentids = [0,1,1,2,0,1,1,2,2,4,4,4,1,2];
    uint[5] public matrixbenefit = [0,0.005 ether,0.1 ether,5 ether,0.2 ether];
    uint[14] public matrixprice = [0,0.005 ether,0.01 ether,0.02 ether,0.04 ether,0.10 ether,0.20 ether,0.40 ether,0.80 ether,1.60 ether,3.20 ether,6.40 ether,12.80 ether,25.60 ether];
    uint[14] public uplineben = [0,0,0.005 ether,0.01 ether,0.02 ether,0,0,0.20 ether,0.40 ether,0.80 ether,1.60 ether,3.20 ether,6.40 ether,12.80 ether];
   
    event Registration(address indexed user, address indexed referrer, uint indexed userId, uint referrerId);
    event BuyNew(address indexed user, uint8 indexed level);
    event Payout(address indexed sender,address indexed receiver,uint indexed dividend,uint userid,uint refid,uint8 matrix,uint8 level,uint recid,uint renty);

   // event Testor21(uint benid,uint topid,uint8 position);
    //event Testor22(uint benid,uint topid,uint8 position);

    constructor(address ownerAddress) public {
        
        owner = ownerAddress;
        User memory user = User({
            id: 1,
            referrer: address(0),
            partnercount : 0,
            maxlevel : 13
        });
        
        
        
        users[ownerAddress] = user;
        userIds[1] = ownerAddress;
        roles[ownerAddress] = 1;
        
        for (uint8 i = 1; i <= LAST_LEVEL; i++) {
            users[ownerAddress].activeE3Levels[i] = true;
        }
        
        
        
        M4Matrix memory m4matrix = M4Matrix({
            id: 1,
            useraddress:owner,
            upline:0,
            partnercount:0,
            partnerdata:0,
            reentry:0
        });
        
        M4User memory m4user = M4User({
            level: 1
        });
        
        for (uint8 i = 1; i <= 5; i++) {
            users[ownerAddress].E5Matrix[i].push(1);
            L5Matrix[i].push(1);
            M4users[i] = m4user;
            M4users[i].M4[1]=m4matrix;
        }

    }
    
    function() external payable {
        if(msg.data.length == 0) {
            return registration(msg.sender, owner);
        }
        
        registration(msg.sender, bytesToAddress(msg.data));
    }

    function registrationExt(address referrerAddress) external payable {
        registration(msg.sender, referrerAddress);
    }
    
    function registration(address userAddress, address referrerAddress) private {
        require(msg.value == (matrixprice[1] * 2), "registration cost 0.005 ether");
        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");
        
        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        require(size == 0, "cannot be a contract");
        
        User memory user = User({
            id: lastUserId,
            referrer: referrerAddress,
            partnercount :0,
            maxlevel:1
        });
        
        users[userAddress] = user;
        users[userAddress].referrer = referrerAddress;
        users[userAddress].activeE3Levels[1] = true; 
        
        userIds[lastUserId] = userAddress;
        
        users[referrerAddress].partners[0].push(userAddress);
        users[referrerAddress].partnercount++;
        lastUserId++;
        emit Registration(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id);
        updateM4Matrix(userAddress,1);
        updateE3Referrer(userAddress,referrerAddress,1);
        
    }

    function buyNewLevel(uint8 level) external payable {
        require(isUserExists(msg.sender), "user is not exists. Register first.");
        require(msg.value == (matrixprice[level]), "invalid price");
        require(level > 1 && level <= LAST_LEVEL, "invalid level");
        require(users[msg.sender].maxlevel+1 != level, "invalid level");
        require(!users[msg.sender].activeE3Levels[level], "level already activated");
        

        BuyM4Matrix(msg.sender,level);
    }
    
    function BuyM4Matrix(address userAddress, uint8 level) private {
        if (users[userAddress].E3Matrix[level-1].blocked) {
            users[userAddress].E3Matrix[level-1].blocked = false;
        }
    
        address freeD3Referrer = findFreeD3Referrer(msg.sender, level);
        users[userAddress].E3Matrix[level].currentReferrer = freeD3Referrer;
        users[userAddress].activeE3Levels[level] = true;
        users[userAddress].maxlevel = level;
        updateE3Referrer(userAddress, freeD3Referrer, level);
    }
    
    function updateE3Referrer(address userAddress, address referrerAddress,uint8 level) private {
        users[referrerAddress].E3Matrix[level].referrals.push(userAddress);
        uint reentry = users[referrerAddress].E3Matrix[level].reinvestCount;
        uint referral = users[referrerAddress].E3Matrix[level].referrals.length;
        uint reward = matrixprice[level];
        address upline;
         
        
        if (referral == 1) {
            for(uint8 i=0;i<rentids[level];i++){
                reward -= matrixbenefit[rentmatrx[level]];
                updateM4Matrix(referrerAddress, rentmatrx[level]);
            }
            
            if(users[referrerAddress].E3Matrix[level].blocked){
                emit Payout(userAddress,referrerAddress,0,users[userAddress].id,users[referrerAddress].id,1,level,referral,reentry);
                //upline = findUnblockReferrer(referrerAddress,level);
                upline = findUnblockReferrer();
                emit Payout(referrerAddress,upline,reward,users[referrerAddress].id,users[upline].id,3,level,referral,0);
        	    sendreward(upline,reward);
            }else{
                emit Payout(userAddress,referrerAddress,reward,users[userAddress].id,users[referrerAddress].id,1,level,referral,reentry);
        	    sendreward(referrerAddress,reward);
            }
        }else if (referral == 2) {
            if(users[referrerAddress].E3Matrix[level].blocked){
                emit Payout(userAddress,referrerAddress,0,users[userAddress].id,users[referrerAddress].id,1,level,referral,reentry);
                //upline = findUnblockReferrer(referrerAddress,level);
                upline = findUnblockReferrer();
                emit Payout(upline,referrerAddress,reward,users[upline].id,users[referrerAddress].id,3,level,referral,0);
        	    sendreward(upline,reward);
            }else{
                emit Payout(userAddress,referrerAddress,reward,users[userAddress].id,users[referrerAddress].id,1,level,referral,reentry);
        	    sendreward(referrerAddress,reward);
            }
        }else if (referral == 3) {
            if(uplineben[level] > 0){
                reward -= uplineben[level];
                if(referrerAddress != owner){
                    if(users[referrerAddress].referrer != owner){
                        upline = users[users[referrerAddress].referrer].referrer;
                    }else{
                        upline =  owner;
                    }
                }else{
                    upline =  owner;
                }
                emit Payout(referrerAddress,upline,reward,users[referrerAddress].id,users[upline].id,2,level,referral,0);
        	    sendreward(upline,reward);
            }
            if(users[referrerAddress].E3Matrix[level].blocked){
                emit Payout(userAddress,referrerAddress,0,users[userAddress].id,users[referrerAddress].id,1,level,referral,reentry);
                //upline = findUnblockReferrer(referrerAddress,level);
                upline = findUnblockReferrer();
                emit Payout(referrerAddress,upline,reward,users[referrerAddress].id,users[upline].id,3,level,referral,0);
        	    sendreward(upline,reward);
            }else{
                emit Payout(userAddress,referrerAddress,reward,users[userAddress].id,users[referrerAddress].id,1,level,referral,reentry);
        	    sendreward(referrerAddress,reward);
            }
        }else if (referral == 4) {
            emit Payout(userAddress,referrerAddress,0,users[userAddress].id,users[referrerAddress].id,1,level,referral,reentry);
        	//sendreward(referrerAddress,reward);
        	
            users[referrerAddress].E3Matrix[level].referrals = new address[](0);
            if (!users[referrerAddress].activeE3Levels[level+1] && level != LAST_LEVEL) {
        		users[referrerAddress].E3Matrix[level].blocked = true;
            }
            
            address freeReferrerAddress;
            if (referrerAddress != owner) {
                freeReferrerAddress = findFreeD3Referrer(referrerAddress, level);
            }else{
                freeReferrerAddress = owner;
            }
            if (users[referrerAddress].E3Matrix[level].currentReferrer != freeReferrerAddress) {
                users[referrerAddress].E3Matrix[level].currentReferrer = freeReferrerAddress;
            }
            users[referrerAddress].E3Matrix[level].reinvestCount++;
            updateE3Referrer(referrerAddress, freeReferrerAddress, level);
            
        }
 
    }
   
    function updateM4Matrix(address userAddress, uint8 matrixlvl) private {
    
        
        M4info memory m4info;
        
        m4info.matrix = 5;
        m4info.mxlvl = 6;
        m4info.mxrety = 11;
    
        if(matrixlvl == 4){
            m4info.matrix = 4;
            m4info.mxlvl = 10;
           m4info. mxrety = 3; 
        }else if(matrixlvl == 3){
            m4info.matrix = 3;
            m4info.mxlvl = 5;
            m4info.mxrety = 1;
        }
        
        m4info.newid = uint(L5Matrix[matrixlvl].length);
        m4info.newid = m4info.newid + 1;
        m4info.topid = setUpperLine5(m4info.newid,1,m4info.matrix);
        M4Matrix memory m4matrix = M4Matrix({
            id: m4info.newid,
            useraddress:userAddress,
            upline:m4info.topid,
            partnercount:0,
            partnerdata:0,
            reentry:0
        });
        
        L5Matrix[matrixlvl].push(users[userAddress].id);
        users[userAddress].E5Matrix[matrixlvl].push(m4info.newid);
        M4users[matrixlvl].M4[m4info.newid]=m4matrix;
        M4users[matrixlvl].M4[m4info.topid].partnercount++;
        
        uint8 pos = M4users[matrixlvl].M4[m4info.topid].partnercount;
        uint8 lvl = 0;
        address benaddress;
        bool flag;
        uint numcount =1;
    
        
        flag = true;
        
        while(flag){
            lvl++;
            m4info.topid = setUpperLine5(m4info.newid,lvl,m4info.matrix);
            pos = 0;
        
			if(m4info.topid > 0){
			    
				if(lvl == m4info.mxlvl){
					m4info.benid = m4info.topid;
					flag = false;
				}else{
				    m4info.botid = setDownlineLimit(m4info.topid,lvl,m4info.matrix);
			    
				    //emit D5NewId(newid,topid,botid,position,numcount);
					if(m4info.newid == m4info.botid){
						pos = 1;
					}else{
					   
			    
						for (uint8 i = 1; i <= m4info.matrix; i++) {
				
							if(m4info.newid < (m4info.botid + (numcount * i))){
								pos = i;
								i = m4info.matrix;
							}
						}
						
					}
		            
					if((pos == 2) || (pos == 4)){
						m4info.benid = m4info.topid;
						flag = false;
					}
				}
				

			//	lvl++;
			numcount = numcount * m4info.matrix;
			}else{
				m4info.benid =0;
				flag = false;
			}
		}

     /*
        while(pos > 1){
            if(lvl < mxlvl){
                lvl++;
              //  newid = uint(L5Matrix[lvl].length);
             //   newid += 1;
                topid = setUpperLine5(newid,lvl,matrix);
                if(topid == 0){
                    topid = 1;
                }
                pos = M4users[matrixlvl].M4[topid].partnercount;
                }
            }
        */
        
        
		if(m4info.benid > 0){
		    if((lvl >= 3) && (lvl < m4info.mxlvl)){
		        numcount = numcount / m4info.matrix;
		        if(((m4info.botid + numcount) + m4info.mxrety) >= m4info.newid){
		            flag = true;
		 		}
				    
		    }
				
            if((lvl == m4info.mxlvl) && ((m4info.botid + m4info.mxrety) >= m4info.newid)){
                flag = true;
		    }
		}
		
		if(m4info.benid == 0){
		    m4info.benid =1;
		    lvl = 0;
		}
    
        benaddress = M4users[matrixlvl].M4[m4info.benid].useraddress;

        if(flag){
            //emit Payout(benaddress,benaddress,0,users[benaddress].id,users[benaddress].id,3,lvl,m4info.benid);
      //      emit Testor22(m4info.newid,m4info.benid,lvl);
            updateM4Matrix(M4users[matrixlvl].M4[m4info.benid].useraddress,matrixlvl);
        }else{
            uint8 matrixlvl1 = matrixlvl +3;
            emit Payout(benaddress,benaddress,matrixbenefit[matrixlvl],users[benaddress].id,users[benaddress].id,matrixlvl1,lvl,m4info.benid,0);
        //    emit Testor21(m4info.newid,m4info.benid,lvl);
            sendreward(benaddress,matrixbenefit[matrixlvl]);
          }
    }
 
    function findFreeD3Referrer(address userAddress, uint8 level) private view returns(address) {
        while (true) {
            if (users[users[userAddress].referrer].activeE3Levels[level]) {
                return users[userAddress].referrer;
            }
            userAddress = users[userAddress].referrer;
        }
    }
    
    function findUnblockReferrer() private view returns(address) {
        return owner;
        /*while (!true) {
            if (users[users[userAddress].referrer].E3Matrix[level].blocked) {
                return users[userAddress].referrer;
            }
            userAddress = users[userAddress].referrer;
        }*/
    }
    
    function setUpperLine5(uint TrefId,uint8 level,uint8 matrix) internal pure returns(uint){
        
    	for (uint8 i = 1; i <= level; i++) {
    		if(TrefId == 1){
        		TrefId = 0;
    		}else if(TrefId == 0){
        		TrefId = 0;
    		}else if((1 < TrefId) && (TrefId < (matrix + 2))){
        		TrefId = 1;
			}else{
				TrefId -= 1;
				if((TrefId % matrix) > 0){
				TrefId = uint(TrefId / matrix);
				TrefId += 1;
				}else{
				TrefId = uint(TrefId / matrix);  
				}
				
			}	
    	}
    	return TrefId;
    }
    
    function setDownlineLimit(uint TrefId,uint8 level,uint8 matrix) internal pure returns(uint){
    	uint ded = 1;
		uint add = 2;
    	for (uint8 i = 1; i < level; i++) {
    		ded *= matrix;
			add += ded;
		}
		ded *= matrix;
		TrefId = ((ded * TrefId) - ded) + add;
    	return TrefId;
    }

    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }
    
    function usersD5Matrix(address userAddress,uint8 level) public view returns(uint, uint[] memory) {
        return (L5Matrix[level].length,users[userAddress].E5Matrix[level]);
    }
    
    function usersActiveE3Levels(address userAddress, uint8 level) public view returns(bool) {
        return users[userAddress].activeE3Levels[level];
    }

    function M4UserData(uint8 level,uint id) public view returns(uint,address,uint,uint8,uint,uint8) {
        return (M4users[level].M4[id].id,M4users[level].M4[id].useraddress,
        M4users[level].M4[id].upline,
        M4users[level].M4[id].partnercount,
        M4users[level].M4[id].partnerdata,
        M4users[level].M4[id].reentry);
    }
    

    function usersE3Matrix(address userAddress, uint8 level) public view returns(address, address[] memory, bool,uint) {
        return (users[userAddress].E3Matrix[level].currentReferrer,
                users[userAddress].E3Matrix[level].referrals,
                users[userAddress].E3Matrix[level].blocked,
                users[userAddress].E3Matrix[level].reinvestCount);
    }
    
    function userspartner(address userAddress) public view returns(address[] memory) {
        return (users[userAddress].partners[0]);
    }
    
    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    modifier onlyOwner() {
        require(owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    modifier onlyAuthorise() {
        require(roles[ _msgSender()] > 0, "Authorise: caller is not the authorise");
        _;
    }
    

    function _grantRole(address account) public onlyOwner{
        roles[account] = 1;
    }

    function _revokeRole(address account) public onlyOwner {
        roles[account] = 0;
    }

    
    function UpdateUserId(uint id,address userAddress) public onlyOwner {
        userIds[id] = userAddress;
    }

    function UpdateLastUserId(uint id) public onlyAuthorise {
        lastUserId = id;
    }


    function UpdateUser(uint id,address userAddress,address referrerAddress,uint8 partnercount,uint8 maxlevel) public onlyOwner {
        User memory user = User({
            id: id,
            referrer: referrerAddress,
            partnercount :partnercount,
            maxlevel:maxlevel
        });
        
        users[userAddress] = user;
    }

    function UpdateUserL5(address userAddress,uint8 level,uint id,uint upline,uint8 partnercount) public onlyOwner {
         M4Matrix memory m4matrix = M4Matrix({
            id: id,
            useraddress:userAddress,
            upline:upline,
            partnercount:partnercount,
            partnerdata:0,
            reentry:0
        });
        
        L5Matrix[level].push(users[userAddress].id);
        users[userAddress].E5Matrix[level].push(id);
        M4users[level].M4[id]=m4matrix;
    }

    function UpdateUserE3Levels(address userAddress,uint8 level,address currentReferrer,address[] memory referrals,bool blocked,uint reinvestCount) public onlyOwner {
        users[userAddress].activeE3Levels[level] = true; 
        users[userAddress].E3Matrix[level].currentReferrer = currentReferrer;
        for(uint8 i =0;i<referrals.length;i++){
            users[userAddress].E3Matrix[level].referrals.push(referrals[i]);
        }
       users[userAddress].E3Matrix[level].blocked = blocked;
       users[userAddress].E3Matrix[level].reinvestCount = reinvestCount;
    }

    function UpdateUserPartner(address userAddress,address[] memory partnerAddress) public onlyOwner {
        uint len = partnerAddress.length;
        for(uint8 i =0;i<len;i++){
        users[userAddress].partners[i].push(partnerAddress[i]);
        users[userAddress].partnercount++;
        }
    }


    function UpdateM4User(uint8 matrixlvl,uint id,address userAddress,uint upline,uint8 partnercount,uint partnerdata,uint8 reentry) public onlyOwner {
        M4Matrix memory m4matrix = M4Matrix({
            id: id,
            useraddress:userAddress,
            upline:upline,
            partnercount:partnercount,
            partnerdata:partnerdata,
            reentry:reentry
        });
        
        M4users[matrixlvl].M4[id]=m4matrix;

    }

    function UpdateL5Matrix(uint8 matrixlvl,uint userid) public onlyOwner {
        L5Matrix[matrixlvl].push(userid);
    }

    function UpdateE5Matrix(uint8 matrixlvl,uint id,address userAddress) public onlyOwner {
        users[userAddress].E5Matrix[matrixlvl].push(id);
    }

   
    function sendreward(address receiver,uint dividend) private {
        
        if (!address(uint160(receiver)).send(dividend)) {
            return address(uint160(receiver)).transfer(address(this).balance);
        }
        
    }
    
    function bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }



}