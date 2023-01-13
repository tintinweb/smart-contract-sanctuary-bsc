// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

uint8 constant UNILEVEL = 1; // Unilevel matrix (Sun, unlimited leg)
uint8 constant BINARY = 2; // Binary marix - Tow leg
uint8 constant TERNARY = 3; // Ternary matrix - Three leg

library Algorithms {
	// Factorial x! - Use recursion
	function Factorial(uint256 _x) internal pure returns (uint256 _r) {
		if (_x == 0) return 1;
		else return _x * Factorial(_x - 1);
	}

	// Exponentiation x^y - Algorithm: "exponentiation by squaring".
	function Exponential(uint256 _x, uint256 _y) internal pure returns (uint256 _r) {
		// Calculate the first iteration of the loop in advance.
		uint256 result = _y & 1 > 0 ? _x : 1;
		// Equivalent to "for(y /= 2; y > 0; y /= 2)" but faster.
		for (_y >>= 1; _y > 0; _y >>= 1) {
			_x = MulDiv18(_x, _x);
			// Equivalent to "y % 2 == 1" but faster.
			if (_y & 1 > 0) {
				result = MulDiv18(result, _x);
			}
		}
		_r = result;
	}

	// https://github.com/paulrberg/prb-math
	// @notice Emitted when the ending result in the fixed-point version of `mulDiv` would overflow uint256.
	error MulDiv18Overflow(uint256 x, uint256 y);

	function MulDiv18(uint256 x, uint256 y) internal pure returns (uint256 result) {
		// How many trailing decimals can be represented.
		uint256 UNIT = 1e18;
		// Largest power of two that is a divisor of `UNIT`.
		uint256 UNIT_LPOTD = 262144;
		// The `UNIT` number inverted mod 2^256.
		uint256 UNIT_INVERSE = 78156646155174841979727994598816262306175212592076161876661_508869554232690281;

		uint256 prod0;
		uint256 prod1;

		assembly {
			let mm := mulmod(x, y, not(0))
			prod0 := mul(x, y)
			prod1 := sub(sub(mm, prod0), lt(mm, prod0))
		}
		if (prod1 >= UNIT) {
			revert MulDiv18Overflow(x, y);
		}
		uint256 remainder;
		assembly {
			remainder := mulmod(x, y, UNIT)
		}
		if (prod1 == 0) {
			unchecked {
				return prod0 / UNIT;
			}
		}
		assembly {
			result := mul(
				or(
					div(sub(prod0, remainder), UNIT_LPOTD),
					mul(sub(prod1, gt(remainder, prod0)), add(div(sub(0, UNIT_LPOTD), UNIT_LPOTD), 1))
				),
				UNIT_INVERSE
			)
		}
	}
}

library AffiliateCreator {
	// https://stackoverflow.com/questions/67893318/solidity-how-to-represent-bytes32-as-string
	function ToHex16(bytes16 data) internal pure returns (bytes32 result) {
		result =
			(bytes32(data) & 0xFFFFFFFFFFFFFFFF000000000000000000000000000000000000000000000000) |
			((bytes32(data) & 0x0000000000000000FFFFFFFFFFFFFFFF00000000000000000000000000000000) >> 64);
		result =
			(result & 0xFFFFFFFF000000000000000000000000FFFFFFFF000000000000000000000000) |
			((result & 0x00000000FFFFFFFF000000000000000000000000FFFFFFFF0000000000000000) >> 32);
		result =
			(result & 0xFFFF000000000000FFFF000000000000FFFF000000000000FFFF000000000000) |
			((result & 0x0000FFFF000000000000FFFF000000000000FFFF000000000000FFFF00000000) >> 16);
		result =
			(result & 0xFF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000) |
			((result & 0x00FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF0000) >> 8);
		result =
			((result & 0xF000F000F000F000F000F000F000F000F000F000F000F000F000F000F000F000) >> 4) |
			((result & 0x0F000F000F000F000F000F000F000F000F000F000F000F000F000F000F000F00) >> 8);
		result = bytes32(
			0x3030303030303030303030303030303030303030303030303030303030303030 +
				uint256(result) +
				(((uint256(result) + 0x0606060606060606060606060606060606060606060606060606060606060606) >> 4) &
					0x0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F) *
				7
		);
	}

	function ToHex(bytes32 data) internal pure returns (string memory) {
		return string(abi.encodePacked("0x", ToHex16(bytes16(data)), ToHex16(bytes16(data << 128))));
	}

	function Create(bytes32 _Bytes32, uint8 _len) internal pure returns (bytes16 _r) {
		string memory s = ToHex(_Bytes32);
		bytes memory b = bytes(s);
		bytes memory r = new bytes(_len);
		for (uint i = 0; i < _len; ++i) r[i] = b[i + 3];
		return bytes16(bytes(r));
	}

	function Create(uint8 _len) internal view returns (bytes16 _r) {
		return
			Create(
				bytes32(keccak256(abi.encodePacked(msg.sender, block.timestamp, block.difficulty, block.number * _len))),
				_len
			);
	}
}

library Address {
	function isContract(address account) internal view returns (bool) {
		return account.code.length > 0;
	}
}

library Uint32Array {
	function RemoveValue(uint32[] storage _Array, uint32 _Value) internal {
		require(_Array.length > 0, "Uint32: Can't remove from empty array");
		// Move the last element into the place to delete
		for (uint32 i = 0; i < _Array.length; ++i) {
			if (_Array[i] == _Value) {
				_Array[i] = _Array[_Array.length - 1];
				break;
			}
		}
		_Array.pop();
	}

	function RemoveIndex(uint32[] storage _Array, uint64 _Index) internal {
		require(_Array.length > 0, "Uint32: Can't remove from empty array");
		require(_Array.length > _Index, "Index out of range");
		// Move the last element into the place to delete
		_Array[_Index] = _Array[_Array.length - 1];
		_Array.pop();
	}

	function AddNoDuplicate(uint32[] storage _Array, uint32 _Value) internal {
		for (uint32 i = 0; i < _Array.length; ++i) if (_Array[i] == _Value) return;
		_Array.push(_Value);
	}

	function TrimRight(uint32[] memory _Array) internal pure returns (uint32[] memory _Return) {
		require(_Array.length > 0, "Uint32: Can't trim from empty array");
		uint32 count;
		for (uint32 i = 0; i < _Array.length; ++i) {
			if (_Array[i] != 0) count++;
			else break;
		}
		_Return = new uint32[](count);
		for (uint32 j = 0; j < count; ++j) {
			_Return[j] = _Array[j];
		}
	}
}

// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.8.0 <0.9.0;

import "./TMatrix.sol";
import "./TXPro.sol";
import "./Library.sol";

abstract contract TAccount is TMatrix, XProgram {
	using Address for address;
	using AffiliateCreator for bytes32;
	using Uint32Array for uint32[];

	struct Account {
		uint32 AccountID;
		bytes16 Affiliate; // User can modify and Using like AccountID
		address Address; // One address can have multiple accounts
		uint32 RegTime; // Registration datetime
		bool Auto; // Auto next level in XProgram
		bool Stoped; // User can stop account and withdraw all
	}

	uint32 private numAccount; // Total account number
	mapping(uint32 => Account) Accounts; // Account info of AccountID
	mapping(address => uint32[]) AccountsOf; // AccountIDs of address
	mapping(bytes16 => uint32) AffiliateTo; // Affiliate to AccountID

	constructor(uint32 _Starting) TMatrix(_Starting) {
		InitializeAccount(_Starting);
	}

	function InitializeAccount(uint32 _Starting) private {
		Accounts[_Starting] = Account({
			AccountID: _Starting,
			Affiliate: bytes16(0),
			Address: msg.sender,
			RegTime: uint32(block.timestamp),
			Auto: true,
			Stoped: false
		});
		AccountsOf[msg.sender].push(_Starting);
	}

	function _registration(address _NewAddress) internal {
		uint32 sponsorid = _FindFreeSponsorID();
		_registration(_NewAddress, sponsorid);
	}

	function _registration(address _NewAddress, uint32 _SponsorID) internal {
		require(_NewAddress.isContract() == false, "Registration: can not contract");
		require(_SponsorID != 0 && Accounts[_SponsorID].AccountID == _SponsorID, "Registration: sponsor id invalid");

		uint32 newid = _AccountIDCreator();

		// Init new account
		Accounts[newid] = Account({
			AccountID: newid,
			Affiliate: bytes16(0),
			Address: _NewAddress,
			RegTime: uint32(block.timestamp),
			Auto: true,
			Stoped: false
		});
		AccountsOf[_NewAddress].push(newid);

		_InitAccountForMaxtrixes(newid, _SponsorID); // Initialize for Matrixes
		_InitAccountForXProgram(newid); // Initialization and Activation for each xprogram
	}

	function _AccountIDCreator() internal returns (uint32 _NewAccountID) {
		while (true) {
			unchecked {
				++numAccount;
				if (Accounts[numAccount].AccountID == 0) return numAccount;
			}
		}
	}

	function _AffiliateCreator() internal view returns (bytes16 _Affiliate) {
		while (true) {
			_Affiliate = AffiliateCreator.Create(8);
			if (AffiliateTo[_Affiliate] == 0) return _Affiliate;
		}
	}

	function _UpdateAddress(uint32 _AccountID, address _NewAddress) internal {
		Accounts[_AccountID].Address = _NewAddress;
		AccountsOf[msg.sender].RemoveValue(_AccountID);
		AccountsOf[_NewAddress].AddNoDuplicate(_AccountID);
	}

	function _UpdateAffiliate(uint32 _AccountID, bytes16 _NewAffiliate) internal {
		AffiliateTo[Accounts[_AccountID].Affiliate] = 0;
		AffiliateTo[_NewAffiliate] = _AccountID;
		Accounts[_AccountID].Affiliate = _NewAffiliate;
	}

	function _AccountsOf(address _address) internal view returns (uint32[] memory _AccountIDs) {
		return AccountsOf[_address];
	}

	// Return a account id LATEST/NEWEST of Address
	function _GetLatestAccountsOf(address _address) internal view returns (uint32 _AccountID) {
		uint32[] memory accounts = AccountsOf[_address];
		if (accounts.length > 0) {
			_AccountID = accounts[0];
			for (uint32 i = 1; i < accounts.length; ++i)
				if (Accounts[accounts[i]].RegTime > Accounts[_AccountID].RegTime) _AccountID = accounts[i];
		} else return 0;
	}
}

// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.8.0 <0.9.0;

import "./Library.sol";

abstract contract Matrix {
	mapping(uint8 => mapping(uint256 => uint256)) MaxY; // [MATRIX][X] -> MaxY = x^y
	mapping(uint8 => mapping(uint256 => mapping(uint256 => uint32))) MatrixXY; // [MATRIX][X][Y] -> NodeID
	mapping(uint32 => mapping(uint8 => uint256)) NodeX; // [NodeID][MATRIX] -> X
	mapping(uint32 => mapping(uint8 => uint256)) NodeY; // [NodeID][MATRIX] -> Y

	mapping(uint8 => mapping(uint256 => uint256)) YCount; // [MATRIX][X] -> Y Existed Count
	mapping(uint8 => mapping(uint256 => bool)) XisFull; // [MATRIX][X] -> X is Full
	mapping(uint8 => mapping(uint256 => uint32[])) MissingLeg; // [MATRIX][X] -> NodeID

	// For Overflow
	uint256 CurrentX_B; // ready to add node
	uint256 CurrentY_B; // ready to add node
	uint256 CurrentX_T; // ready to add node
	uint256 CurrentY_T; // ready to add node

	function _FindUplineIDByOverflow(uint32 _NodeID, uint8 _MATRIX) internal returns (uint32 _UplineID) {
		if (_MATRIX == BINARY) {
			uint256 uy = (CurrentY_B / 2) + (CurrentY_B % 2 != 0 ? 1 : 0);
			_UplineID = MatrixXY[BINARY][CurrentX_B - 1][uy];

			// Update matrix
			MatrixXY[BINARY][CurrentX_B][CurrentY_B] = _NodeID;
			if (CurrentY_B == MaxY[BINARY][CurrentX_B]) {
				++CurrentX_B;
				CurrentY_B = 1;
			} else ++CurrentY_B;
		} else {
			uint256 uy = (CurrentY_T / 3) + (CurrentY_T % 3 != 0 ? 1 : 0);
			_UplineID = MatrixXY[TERNARY][CurrentX_T - 1][uy];

			// Update matrix
			MatrixXY[TERNARY][CurrentX_T][CurrentY_T] = _NodeID;
			// NodeX[_NodeID][_MATRIX] = CurrentX;
			// NodeY[_NodeID][_MATRIX] = CurrentY;
			// XisFull[_MATRIX][CurrentX] = true; // MaxY & YCount, MissingLeg ???

			if (CurrentY_T == MaxY[TERNARY][CurrentX_T]) {
				++CurrentX_T;
				CurrentY_T = 1;
			} else ++CurrentY_T;
		}
		if (_UplineID == 0) revert("Find upline id fail");
	}

	function _FindFreeSponsorID() internal view returns (uint32 _SponsorID) {
		uint256 uy = (CurrentY_T / 3) + (CurrentY_T % 3 != 0 ? 1 : 0);
		_SponsorID = MatrixXY[TERNARY][CurrentX_T - 1][uy];
		if (_SponsorID == 0) revert("Find sponsor id fail");
	}

	function setMaxY() public {
		for (uint256 i = 0; i < 33; ++i) {
			MaxY[BINARY][i + 1] = 2 ** i; // Algorithms.Exponential(BINARY, i);
			MaxY[TERNARY][i + 1] = 3 ** i; // Algorithms.Exponential(TERNARY, i);
		}
	}
}

abstract contract TMatrix is Matrix {
	uint32 RootID;

	struct Node {
		uint32 NodeID;
		uint32 SponsorID;
		uint8 SL;
	}
	mapping(uint32 => Node) Nodes; // Node of AccountID
	mapping(uint32 => mapping(uint8 => uint32)) UplineIDOf; // [NodeID][MATRIX] -> UplineID
	mapping(uint32 => mapping(uint8 => uint32[])) X1IDs; // [NodeID][MATRIX][POSITION/INDEX] -> ID F1
	mapping(uint32 => mapping(uint8 => uint32[])) PathFromRoot; // [NodeID][MATRIX][XOfRoot] -> UplineID
	mapping(uint32 => mapping(uint8 => uint32[])) PathToSponsor; // [NodeID][MATRIX][XOfSponsor] -> UplineID

	constructor(uint32 _Starting) {
		require(_Starting !=0,"_Starting can not zero");
		RootID = _Starting;
		InitializeMatrix(_Starting);
	}

	function InitializeMatrix(uint32 _Starting) private {
		Nodes[_Starting] = Node({ NodeID: _Starting, SponsorID: 0, SL: 15 });
		CurrentX_B = 2;
		CurrentY_B = 1;
		MatrixXY[BINARY][1][1] = _Starting;
		CurrentX_T = 2;
		CurrentY_T = 1;
		MatrixXY[TERNARY][1][1] = _Starting;
	}

	function _InitAccountForMaxtrixes(uint32 _AccountID, uint32 _SponsorID) internal {
		Nodes[_AccountID] = Node({ NodeID: _AccountID, SponsorID: _SponsorID, SL: 1 });

		// Unilevel matrix
		X1IDs[_SponsorID][UNILEVEL].push(_AccountID);
		PathFromRoot[_AccountID][UNILEVEL] = PathFromRoot[_SponsorID][UNILEVEL];
		PathFromRoot[_AccountID][UNILEVEL].push(_SponsorID);

		// Update sponsor level for upline when node changes from SL1 to SL2
		if (X1IDs[_SponsorID][UNILEVEL].length == 3) _UpdateSponsorLevelForUpline(_AccountID);

		// Binary matrix
		_InitMatrix(_AccountID, BINARY);
		// Ternary matrix
		_InitMatrix(_AccountID, TERNARY);
	}

	function _InitMatrix(uint32 _NodeID, uint8 _MATRIX) internal returns (uint32 _UplineID) {
		_UplineID = _FindUplineIDByOverflow(_NodeID, _MATRIX);
		// Update upline
		X1IDs[_UplineID][_MATRIX].push(_NodeID);
		// Update newnode
		UplineIDOf[_NodeID][_MATRIX] = _UplineID;
		PathFromRoot[_NodeID][_MATRIX] = PathFromRoot[_UplineID][_MATRIX];
		PathFromRoot[_NodeID][_MATRIX].push(_UplineID);
	}

	// function _UpdatePathToSponsor(uint32 _NodeID, uint8 _MATRIX) internal {
	// 	uint32 uid = UplineID[_NodeID][_MATRIX];

	// }

	function _FindUplineIDForXprogram(uint32 _AccountID) internal view returns (uint32 _UplineID) {
		return RootID;
	}

	// Update sponsor level for upline when node changes from SL1 to SL2
	function _UpdateSponsorLevelForUpline(uint32 _NodeID) private {}

	function _SelectX1IDsOfNode(uint32 _NodeID, uint8 _MATRIX) internal view virtual returns (uint32[] memory _NodeIDs) {
		return X1IDs[_NodeID][_MATRIX];
	}
}

// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.8.0 <0.9.0;

import "./TAccount.sol";

contract Tuktu is TAccount {
	constructor(uint32 _Starting) TAccount(_Starting) {}

	modifier onlyAccountOwner(uint32 _AccountID) {
		require(_AccountID != 0 && Accounts[_AccountID].AccountID == _AccountID, "Account: does not existed");
		require(msg.sender == Accounts[_AccountID].Address, "Account: caller is not the owner");
		_;
	}

	fallback() external {}

	receive() external payable {}

	// Registration
	function Registration() public {
		_registration(msg.sender);
	}

	// Register with referral link of sponsor
	function Registration(string memory _SponsorAffiliate, uint32 _SponsorID, address _SponsorAddress) public {
		bytes16 aff = bytes16(bytes(_SponsorAffiliate));
		if (AffiliateTo[aff] != 0 && AffiliateTo[aff] == Accounts[AffiliateTo[aff]].AccountID)
			_registration(msg.sender, AffiliateTo[aff]);
		else if (_SponsorID != 0 && Accounts[_SponsorID].AccountID == _SponsorID) _registration(msg.sender, _SponsorID);
		else if (_SponsorAddress != address(0)) {
			uint32 latestaccountid = _GetLatestAccountsOf(_SponsorAddress);
			latestaccountid != 0 ? _registration(msg.sender, latestaccountid) : _registration(msg.sender);
		} else _registration(msg.sender);
	}

	// Register for someone else, users can register for other users
	function Registration(address _NewAccountAddress, uint32 _SponsorID) public {
		require(_NewAccountAddress != address(0), "Registration: can not zero address");
		(_SponsorID != 0 && Accounts[_SponsorID].AccountID == _SponsorID)
			? _registration(_NewAccountAddress, _SponsorID)
			: _registration(_NewAccountAddress);
	}

	// Create affiliate
	function AffiliateCheckAvailable(string memory _Affiliate) public view returns (bool _ReadyToUse) {
		require(bytes(_Affiliate).length != 0, "Affiliate: can not empty");
		return AffiliateTo[bytes16(bytes(_Affiliate))] == 0; // true is ready to use
	}

	function AffiliateCreate(uint32 _AccountID, string memory _NewAffiliate) public onlyAccountOwner(_AccountID) {
		bytes16 newaff = bytes16(bytes(_NewAffiliate));
		bytes16 oldaff = Accounts[_AccountID].Affiliate;

		if (oldaff == bytes16(0) && bytes(_NewAffiliate).length == 0) {
			// create new
			_UpdateAffiliate(_AccountID, _AffiliateCreator());
		} else if (oldaff == bytes16(0) && bytes(_NewAffiliate).length != 0) {
			// user creat
			require(AffiliateTo[newaff] == 0, "Affiliate: existed");
			_UpdateAffiliate(_AccountID, newaff);
		} else if (oldaff != bytes16(0) && bytes(_NewAffiliate).length != 0) {
			// update
			require(
				keccak256(abi.encodePacked(oldaff)) != keccak256(abi.encodePacked(newaff)),
				"same affiliate already exists"
			);
			_UpdateAffiliate(_AccountID, newaff);
		}
	}

	// Account transfer
	function ChangeAddress(uint32 _AccountID, address _NewAddress) public onlyAccountOwner(_AccountID) {
		require(_NewAddress != address(0), "can not zezo address");
		require(Accounts[_AccountID].Address != _NewAddress, "same address already exists");
		_UpdateAddress(_AccountID, _NewAddress);
	}

	// Dashboard and Treeview
	struct AccountInfo {
		uint32 AccountID;
		string Affiliate;
		address Address;
		uint32 RegTime;
		bool AutoNextLevel;
		bool AccountStoped;
		uint32 SponsorLevel;
	}

	function AccountsOfAddress(address _address) public view returns (uint32[] memory _AccountIDs) {
		require(_address != address(0), "Dashboard: can not zero address");
		_AccountIDs = _AccountsOf(_address);
	}

	function InfoAccount(uint32 _AccountID) public view returns (AccountInfo memory _AccountInfo) {
		return
			_AccountInfo = AccountInfo({
				AccountID: _AccountID,
				Address: Accounts[_AccountID].Address,
				Affiliate: string(abi.encode(Accounts[_AccountID].Affiliate)),
				AutoNextLevel: Accounts[_AccountID].Auto,
				AccountStoped: Accounts[_AccountID].Stoped,
				RegTime: Accounts[_AccountID].RegTime,
				SponsorLevel: Nodes[_AccountID].SL
			});
	}

	function _ReturnAccountInfo(
		uint32 _AccountID,
		uint8 _MATRIX
	) private view returns (AccountInfo[] memory _AccountInfo) {
		uint32[] memory _AccountIDs = _SelectX1IDsOfNode(_AccountID, _MATRIX);
		uint32 len = uint32(_AccountIDs.length);
		if (len > 0) {
			_AccountInfo = new AccountInfo[](len);
			for (uint32 i = 0; i < len; ++i) {
				_AccountInfo[i] = AccountInfo({
					AccountID: _AccountIDs[i],
					Address: Accounts[_AccountIDs[i]].Address,
					Affiliate: string(abi.encode(Accounts[_AccountIDs[i]].Affiliate)),
					AutoNextLevel: Accounts[_AccountIDs[i]].Auto,
					AccountStoped: Accounts[_AccountIDs[i]].Stoped,
					RegTime: Accounts[_AccountIDs[i]].RegTime,
					SponsorLevel: Nodes[_AccountIDs[i]].SL
				});
			}
		}
	}

	function Treeview(uint32 _AccountID, uint8 _MATRIX) public view returns (AccountInfo[] memory _Matrix) {
		require(_AccountID != 0 && Accounts[_AccountID].AccountID == _AccountID, "Account: does not existed");
		require(_MATRIX > 0 && _MATRIX < 4, "Matrix: does not existed");
		return _ReturnAccountInfo(_AccountID, _MATRIX);
	}

	//////////////////////////////////////////////////////////////////////////////////
	function Test(uint256 _Num) public {
		for (uint256 i = 0; i < _Num; ++i) {
			Registration();
		}
	}

	function T_ViewAccount(uint32 _AccountID) public view returns (Account memory _Accounts) {
		return Accounts[_AccountID];
	}

	function T_ViewNode(uint32 _AccountID) public view returns (Node memory _Node) {
		return Nodes[_AccountID];
	}

	function T_SelectF1(uint32 _AccountID, uint8 _MATRIX) public view returns (uint32[] memory _F1) {
		return _SelectX1IDsOfNode(_AccountID, _MATRIX);
	}
	//////////////////////////////////////////////////////////////////////////////////
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./TMatrix.sol";

abstract contract XProgram is TMatrix {
	mapping(uint32 => mapping(uint8 => mapping(uint8 => uint32))) UplineID; // [AccountID][XPro][LEVEL] - Current upline ID in current cycle
	mapping(uint32 => mapping(uint8 => mapping(uint8 => uint16))) RecycleCount; // Number of recycle
	mapping(uint32 => mapping(uint8 => mapping(uint8 => bool))) LevelActived; // Is the level activated or not
	mapping(uint32 => mapping(uint8 => mapping(uint8 => mapping(uint8 => mapping(uint8 => uint32))))) AccountIDOfCycleXY; // [AccountID][XPro][LEVEL][LINE-X][POS-Y]

	function _InitAccountForXProgram(uint32 _AccountID) internal {

		for (uint8 xp = 0; xp < 5; ++xp) {
			// Five XPrograms - 0: X3, 1: X6, 2: X7, 3: X8, 4: X9
            UplineID[_AccountID][xp][1] = _FindUplineIDForXprogram(_AccountID); // Actived level 1
            LevelActived[_AccountID][xp][1] = true;

			// for (uint8 lv = 0; lv < 15; ++lv) {
			// 	Fifteen levels of each xprogram
			// 	UplineID[_AccountID][xp][lv] = _FindUplineIDForXprogram(_AccountID);

            //      RecycleCount[_AccountID][xp][lv] = 0;
			// 	    LevelActived[_AccountID][xp][lv] = false;

            //     for (uint8 x = 0; x < 3; ++x) {
			// 		// Line of each xprogram, max = 3
			// 		for (uint8 y = 0; y < 27; ++y) {
			// 			// Position of each line in xprogram, max = 27
			// 			AccountIDOfCycleXY[_AccountID][xp][lv][x][y] = x * y;
			// 		}
			// 	}
			// }
		}
	}
}