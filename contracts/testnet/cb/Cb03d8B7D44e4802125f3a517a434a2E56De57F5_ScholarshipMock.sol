// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IOKGScholarship.sol";

contract ScholarshipMock is IOKGScholarship {
	mapping(bytes32 => Scholarship) createdScholarship;
	mapping(uint256 => bool) public lockedHeroes;
	struct Scholarship {
		bool active;
		uint256[] heroIds;
		address owner;
		address assignee;
	}

	function scholarship(
		uint256[] calldata heroIds,
		string calldata scholarshipId,
		address assignee,
		bytes calldata signature
	) external override {
		bytes32 id = keccak256(abi.encodePacked(scholarshipId));
		createdScholarship[id] = Scholarship(true, heroIds, msg.sender, assignee);

		for (uint256 i; i < heroIds.length; i++) {
			lockedHeroes[heroIds[i]] = true;
		}

		emit NewScholarship(heroIds, msg.sender, assignee, scholarshipId);
	}

	function cancelScholarship(
		string calldata scholarshipId,
		bytes calldata signature
	) external override {
		bytes32 id = keccak256(abi.encodePacked(scholarshipId));

		Scholarship memory scholarship = createdScholarship[id];
		createdScholarship[id].active = false;
		for (uint256 i; i < scholarship.heroIds.length; i++) {
			lockedHeroes[scholarship.heroIds[i]] = true;
		}

		emit CancelScholarship(
			scholarship.heroIds,
			scholarship.owner,
			scholarship.assignee,
			scholarshipId
		);
	}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IOKGScholarship {
	function scholarship(
		uint256[] calldata heroIds,
		string calldata scholarshipId,
		address assignee,
		bytes calldata signature
	) external;

	function cancelScholarship(
		string calldata scholarshipId,
		bytes calldata signature
	) external;

	event NewScholarship(
		uint256[] heroIds,
		address indexed owner,
		address indexed assignee,
		string scholarId
	);

	event CancelScholarship(
		uint256[] heroIds,
		address indexed owner,
		address indexed assignee,
		string scholarId
	);
}