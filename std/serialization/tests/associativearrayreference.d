/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Aug 6, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module std.serialization.tests.associativearrayreference;

version (unittest):
private:

import std.serialization.serializer;
import std.serialization.archives.xmlarchive;
import std.serialization.tests.util;
import std.traits;

Serializer serializer;
XmlArchive!(char) archive;

class K
{
	int[int] a;
	int[int] b;
}

K k;

void beforeEach ()
{
	archive = new XmlArchive!(char);
	serializer = new Serializer(archive);

	k = new K;
	k.a = [3 : 4, 1 : 2, 39 : 472, 6 : 7];
	k.b = k.a;

	serializer.serialize(k);
}


@describe("serialize associative array references")
{
	@it("should return a serialized associative array and a serialized reference") unittest
	{
	    beforeEach();

		assert(archive.data().containsDefaultXmlContent());
		assert(archive.data().containsXmlTag("object", `runtimeType="` ~ typeid(K).toString() ~ `" type="` ~ fullyQualifiedName!(K) ~ `" key="0" id="0"`));

		assert(archive.data().containsXmlTag("key", `key="0"`));
		assert(archive.data().containsXmlTag("int", `key="0" id="2"`, "1"));
		assert(archive.data().containsXmlTag("value", `key="0"`));
		assert(archive.data().containsXmlTag("int", `key="0" id="3"`, "2"));

		assert(archive.data().containsXmlTag("key", `key="1"`));
		assert(archive.data().containsXmlTag("int", `key="1" id="4"`, "3"));
		assert(archive.data().containsXmlTag("value", `key="1"`));
		assert(archive.data().containsXmlTag("int", `key="1" id="5"`, "4"));

		assert(archive.data().containsXmlTag("key", `key="2"`));
		assert(archive.data().containsXmlTag("int", `key="2" id="6"`, "6"));
		assert(archive.data().containsXmlTag("value", `key="2"`));
		assert(archive.data().containsXmlTag("int", `key="2" id="7"`, "7"));

		assert(archive.data().containsXmlTag("key", `key="3"`));
		assert(archive.data().containsXmlTag("int", `key="3" id="8"`, "39"));
		assert(archive.data().containsXmlTag("value", `key="3"`));
		assert(archive.data().containsXmlTag("int", `key="3" id="9"`, "472"));

		assert(archive.data().containsXmlTag("reference", `key="b"`, "1"));
	}
}

@describe("deserialize associative array references")
{
	@it("should return two deserialized associative arrays pointing to the same data") unittest
	{
	    beforeEach();

		auto kDeserialized = serializer.deserialize!(K)(archive.untypedData);
		assert(kDeserialized.a is kDeserialized.b);
	}
}