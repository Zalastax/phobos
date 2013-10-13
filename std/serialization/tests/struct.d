/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Aug 6, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module std.serialization.tests.struct;

version (unittest):
private:

import std.serialization.Serializer;
import std.serialization.archives.XmlArchive;
import std.serialization.tests.util;

Serializer serializer;
XmlArchive!(char) archive;

struct B
{
	bool opEquals (ref const B) const
	{
		return true;
	}
}

B b;

unittest
{
	archive = new XmlArchive!(char);
	serializer = new Serializer(archive);

	describe("serialize struct") in {
		it("should return a serialized struct") in {
			serializer.reset;
			serializer.serialize(B());

			assert(archive.data().containsDefaultXmlContent());
			assert(archive.data().contains(`<struct type="tests.Struct.B" key="0" id="0"/>`));
		};
	};

	describe("deserialize struct") in {
		it("should return a deserialized struct equal to the original struct") in {
			auto bDeserialized = serializer.deserialize!(B)(archive.untypedData);
			assert(b == bDeserialized);
		};
	};
}