/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Aug 6, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module std.serialization.tests.event;

version (unittest):
private:

import std.serialization.serializer;
import std.serialization.events;
import std.serialization.archives.xmlarchive;
import std.serialization.tests.util;

Serializer serializer;
XmlArchive!(char) archive;

int[] arr;

class Foo
{

	void serializing ()
	{
		arr ~= 1;
	}

	void serialized ()
	{
		arr ~= 2;
	}

	void deserializing ()
	{
		arr ~= 3;
	}

	void deserialized ()
	{
		arr ~= 4;
	}

	mixin OnSerializing!(serializing);
	mixin OnSerialized!(serialized);
	mixin OnDeserializing!(deserializing);
	mixin OnDeserialized!(deserialized);
}

unittest
{
	archive = new XmlArchive!(char);
	serializer = new Serializer(archive);

	describe("serialization events") in {
		it("all four events should be triggered when serializing and deserializing") in {
			serializer.serialize(new Foo);
			serializer.deserialize!(Foo)(archive.untypedData);

			assert(arr == [1, 2, 3, 4]);
		};
	};
}