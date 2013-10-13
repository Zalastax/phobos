/**
 * Copyright: Copyright (c) 2013 Jacob Carlborg. All rights reserved.
 * Authors: Juan Manuel
 * Version: Initial created: Apr 14, 2013
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module std.serialization.tests.arrayofobject;

version (unittest):
private:

import std.serialization.Serializer;
import std.serialization.archives.XmlArchive;
import std.serialization.tests.util;

Serializer serializer;
XmlArchive!(char) archive;

class A
{
	int a;

	this (int value)
	{
		this.a = value;
	}
}

class D
{
	Object[] arr;
}

D d;

unittest
{
	archive = new XmlArchive!(char);
	serializer = new Serializer(archive);

	d = new D;
	d.arr = [cast(Object) new A(1), cast(Object) new A(2)].dup;


	describe("serialize array") in {
		it("shouldn't fail to compile while serializing an Object[] array") in {
			serializer.reset;
			Serializer.register!(A);
			serializer.serialize(d);

			assert(archive.data().containsDefaultXmlContent());
			assert(archive.data().containsXmlTag("object", `runtimeType="tests.ArrayOfObject.D" type="tests.ArrayOfObject.D" key="0" id="0"`));
			assert(archive.data().containsXmlTag("array", `type="object.Object" length="2" key="arr" id="1"`));
			assert(archive.data().containsXmlTag("object", `runtimeType="tests.ArrayOfObject.A" type="const(object.Object)" key="0" id="2"`));
			assert(archive.data().containsXmlTag("int", `key="a" id="3"`, "1"));
			assert(archive.data().containsXmlTag("object", `runtimeType="tests.ArrayOfObject.A" type="const(object.Object)" key="1" id="4"`));
			assert(archive.data().containsXmlTag("int", `key="a" id="5"`, "2"));
		};
	};

	describe("deserialize array") in {
		it("should return a deserialized Object[] array equal to the original array") in {
			auto dDeserialized = serializer.deserialize!(D)(archive.untypedData);

			assert(d.arr.length == dDeserialized.arr.length);
			assert((cast(A) d.arr[0]).a == (cast(A) dDeserialized.arr[0]).a);
			assert((cast(A) d.arr[1]).a == (cast(A) dDeserialized.arr[1]).a);

			Serializer.resetRegisteredTypes();
		};
	};
}
