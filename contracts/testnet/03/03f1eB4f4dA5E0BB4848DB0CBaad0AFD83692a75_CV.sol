// SPDX-License-Identifier: MIT

// Opt. x50000

pragma solidity ^0.8.16;

struct SkillNode {
	string title;
	uint16 xp_years;
	uint16 id;
	uint16 next;
}

struct JobNode {
	string name;
	string title;
	uint16 start_year;
	uint16 finish_year;
	uint16 id;
	uint16 next;
}

uint16 constant MAX = ~uint16(0);

contract SkillsSortedLinkedList {
	SkillNode[] internal skills;
	uint16 internal root_skill = MAX;

	function push_skill(string memory title, uint16 xp_years) internal {
		uint16 len = uint16(skills.length); // This is also the next index

		if (len != 0) {
			SkillNode memory node = skills[root_skill];

			// As there isn't a "prev" property in the struct we can't go back, so we need the actual node that satisfies "prev" < node < "next"
			while (node.next != MAX && node.xp_years > xp_years && skills[node.next].xp_years > xp_years) {
				node = skills[node.next];
			}

			SkillNode memory new_node = SkillNode(title, xp_years, len, node.next);

			// If it's the root and less than the given value
			if (node.id == root_skill && node.xp_years < xp_years) {
				root_skill = len; // Then update the root to the new id
				new_node.next = node.id;
			} else {
				skills[node.id].next = len;
			}

			skills.push(new_node);
		} else {
			root_skill = len;
			skills.push(SkillNode(title, xp_years, len, MAX));
		}
	}
}

contract JobsSortedLinkedList {
	JobNode[] internal jobs;
	uint16 internal root_job = MAX;

	function push_job(string memory name, string memory title, uint16 start_year, uint16 finish_year) internal {
		uint16 len = uint16(jobs.length);

		if (len != 0) {
			JobNode memory node = jobs[root_job];

			// As there isn't a "prev" property in the struct we can't go back, so we need the actual node that satisfies "prev" < node < "next"
			while (node.next != MAX && node.start_year > start_year && jobs[node.next].start_year > start_year) {
				node = jobs[node.next];
			}

			JobNode memory new_node = JobNode(name, title, start_year, finish_year, len, node.next);

			// If it's the root and less than the given value
			if (node.id == root_job && node.start_year < start_year) {
				root_job = len; // Then update the root to the new id
				new_node.next = node.id;
			} else {
				jobs[node.id].next = len;
			}

			jobs.push(new_node);
		} else {
			root_job = len;
			jobs.push(JobNode(name, title, start_year, finish_year, len, MAX));
		}
	}
}

abstract contract String {
	function uint2str(uint256 _i) internal pure returns (string memory _uintAsString) {
		if (_i == 0) {
			return "0";
		}
		uint256 j = _i;
		uint256 len;
		while (j != 0) {
			len++;
			j /= 10;
		}
		bytes memory bstr = new bytes(len);
		uint256 k = len;
		while (_i != 0) {
			k = k - 1;
			uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
			bytes1 b1 = bytes1(temp);
			bstr[k] = b1;
			_i /= 10;
		}
		return string(bstr);
	}

	function addressToString(address _address) internal pure returns(string memory) {
		bytes32 _bytes = bytes32(uint256(uint160(_address)));
		bytes memory HEX = "0123456789abcdef";
		bytes memory _string = new bytes(42);
		_string[0] = '0';
		_string[1] = 'x';
		for(uint i = 0; i < 20; i++) {
			_string[2+i*2] = HEX[uint8(_bytes[i + 12] >> 4)];
			_string[3+i*2] = HEX[uint8(_bytes[i + 12] & 0x0f)];
		}
		return string(_string);
	}
}

interface IERC165 {
	function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

contract SingleERC721 is IERC165 {
	address internal immutable Me;
	string internal uri = "ipfs://QmZ4EYMAsz6mDXXa7SkSWNEdevcWiXzPUcrBE4GSb73HFy";

	event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

	constructor() {
		Me = msg.sender;
		emit Transfer(address(0), Me, 1);
	}

	function balanceOf(address owner) external view returns (uint256 balance) {
		if (owner == Me) {
			balance = 1;
		}
	}

	function ownerOf(uint256 tokenId) external view returns (address) {
		require(tokenId == 1, "No token");
		return Me;
	}

	function tokenURI(uint256 tokenId) external view returns (string memory) {
		require(tokenId == 1, "No token");
		return uri;
	}

	// ERC165 standard
	function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
		return interfaceId == type(IERC165).interfaceId;
	}
}

interface ICV {
	function FullCV() external view returns (string memory ret);
	function Years_of_skill_experience(string memory skill) external view returns (uint256);
}

contract CV is SingleERC721, String, JobsSortedLinkedList, SkillsSortedLinkedList {
	uint256 public constant totalSupply = 1;
	string public constant name = "Evgeny Kolyakov";
	string public constant symbol = "EK";
	string public languages = "and write fluidly in Hebrew, Russian and English";
	string public email = "[email protected]";
	string public education = "B.Sc. Software Engineer from Israel, graduated at Sami Shamoon College";
	string public status = "immediately available";
	address public migrated;

	string[] public Projects;
	string[] public Achievements;

	uint16 public constant The_year_I_was_born = 1986;
	uint16 public constant The_year_I_started_programming = 1993;

	modifier onlyMeNotMigrated() {
		require(msg.sender == Me && tx.origin == Me, "Not me");
		require(migrated == address(0), "Migrated");
		_;
	}

	constructor() {}

	function xp_years(uint16 start_year) private view returns (uint256) {
		return block.timestamp / (365 * 24 * 3600) - (start_year - 1970 + 1);
	}

	function sorted(string[] storage current_arr, mapping(string => uint16) storage current_map, string memory new_key, uint16 new_order) private view returns (string[] memory) {
		string[] memory new_arr = new string[](current_arr.length + 1);
		uint16 i;

		for (; i < current_arr.length; i++) {
			if (current_map[current_arr[i]] < new_order) {
				new_arr[i] = current_arr[i];
			} else {
				break;
			}
		}

		new_arr[i] = new_key;

		for (; i < current_arr.length; i++) {
			new_arr[i + 1] = current_arr[i];
		}

		return new_arr;
	}

	function del(string[] storage arr, uint16 i) private onlyMeNotMigrated {
		uint256 len = arr.length;

		if (len > 1 && i < len - 1) {
			string memory tmp = arr[i];
			arr[i] = arr[len - 1];
			arr[len - 1] = tmp;
		}

		arr.pop();
	}

	function ChangeEmail(string memory _email) external onlyMeNotMigrated {
		email = _email;
	}

	function ChangeEducation(string memory _education) external onlyMeNotMigrated {
		education = _education;
	}

	function ChangeStatus(string memory _status) external onlyMeNotMigrated {
		status = _status;
	}

	function ChangeLanguages(string memory _languages) external onlyMeNotMigrated {
		languages = _languages;
	}

	function AddSkills(string[] memory _skills, uint16[] memory _xp_years) external onlyMeNotMigrated {
		require(_skills.length == _xp_years.length, "Array length missmatch");

		for (uint16 i; i < _skills.length; i++) {
			push_skill(_skills[i], _xp_years[i]);
		}
	}

	function AddJobs(string[] memory jobs, string[] memory titles, uint16[] memory start_years, uint16[] memory finish_years) external onlyMeNotMigrated {
		require(jobs.length == titles.length && titles.length == start_years.length && start_years.length == finish_years.length, "Array length missmatch");

		for (uint16 i; i < jobs.length; i++) {
			push_job(jobs[i], titles[i], start_years[i], finish_years[i]);
		}
	}

	function DelProject(uint16 i) external onlyMeNotMigrated {
		del(Projects, i);
	}

	function DelAchievement(uint16 i) external onlyMeNotMigrated {
		del(Achievements, i);
	}

	function AddProjects(string[] memory projects) external onlyMeNotMigrated {
		for (uint16 i; i < projects.length; i++) {
			Projects.push(projects[i]);
		}
	}

	function AddAchievements(string[] memory achievements) external onlyMeNotMigrated {
		for (uint16 i; i < achievements.length; i++) {
			Achievements.push(achievements[i]);
		}
	}

	function SetTokenURI(string memory _uri) external onlyMeNotMigrated {
		uri = _uri;
	}

	function Migrate(address to) external onlyMeNotMigrated {
		migrated = to;
	}

	function Years_of_experience() external view returns (uint256) {
		return xp_years(The_year_I_started_programming);
	}

	function FullCV() external view returns (string memory ret) {
		if (migrated != address(0)) {
			ret = ICV(migrated).FullCV(); // explicit conversion
			return ret;
		}

		ret = string(abi.encodePacked("Hello, my name is ", name, ". "));
		ret = string(abi.encodePacked(ret, "I'm a ", uint2str(xp_years(The_year_I_was_born)), " years old ", education, ". "));
		ret = string(abi.encodePacked(ret, "My email is ", email, " and I'm ", status, ". "));
		ret = string(abi.encodePacked(ret, "I speak ", languages, ". "));
		ret = string(abi.encodePacked(ret, "My skills in years are: "));

		uint16 i = root_skill;

		for (; i != MAX; i = skills[i].next) {
			ret = string(abi.encodePacked(ret, skills[i].title, "(", uint2str(skills[i].xp_years)));
			if (skills[i].next != MAX) {
				ret = string(abi.encodePacked(ret, "), "));
			} else {
				ret = string(abi.encodePacked(ret, ") "));
			}
		}

		ret = string(abi.encodePacked(ret, "and a few more. I worked at: "));

		i = root_job;

		for (; i != MAX; i = jobs[i].next) {
			ret = string(abi.encodePacked(ret, jobs[i].name, " from ", uint2str(jobs[i].start_year), " to ", uint2str(jobs[i].finish_year), " as ", jobs[i].title, " "));
		}

		ret = string(abi.encodePacked(ret, "I always worked on personal projects after work and here're some of them: "));

		for (i = 0; i < Projects.length; i++) {
			ret = string(abi.encodePacked(ret, Projects[i], ", "));
		}

		// I know that "and" shouldn't be followed by a comma, but to remove the last comma it's a bit of a mess.
		ret = string(abi.encodePacked(ret, "and many more. Also I have a few personal achievements: "));

		for (i = 0; i < Achievements.length; i++) {
			ret = string(abi.encodePacked(ret, Achievements[i], " "));
		}

		string memory addr = addressToString(address(this));

		ret = string(abi.encodePacked(ret, "and probably a few more. I'd say my best quality is that I learn Really fast. I started to learn programming at the age of 7 when my parents sent me to a computer-camp and we studied QBasic, fell in love with it and here I am :) My avatar can be found at https://polygon.nftscan.com/", addr, "/1 and the latest CV is always available at https://polygonscan.com/address/", addr, "#readContract#F1"));
	}
}